module PgHero
  module Methods
    module Citus
      def citus_version
        @citus_version ||= select_one("SHOW citus.version")
      end

      def citus_available?
        select_one("SELECT COUNT(*) AS count FROM pg_available_extensions WHERE name = 'citus'") > 0
      end

      # only cache if true
      def citus_enabled?
        @citus_enabled ||= citus_readable?
      end

      def citus_extension_enabled?
        select_one("SELECT COUNT(*) AS count FROM pg_extension WHERE extname = 'citus'") > 0
      end

      def citus_readable?
        select_all("SELECT 1 FROM pg_dist_partition LIMIT 1")
        true
      rescue ActiveRecord::StatementInvalid
        false
      end

      def nodes
        select_all <<-SQL
          WITH node_size AS
            (SELECT nodename,
                    RESULT AS node_size
             FROM run_command_on_workers($cmd$ SELECT pg_database_size(current_database()); $cmd$)),
               node_stats AS
            ( SELECT placements.nodename AS name,
                     nodes.isactive AS status,
                     count(*) AS shard_count
             FROM pg_dist_shard_placement placements,
                  pg_dist_node nodes
             WHERE placements.nodename = nodes.nodename
             GROUP BY placements.nodename,
                      nodes.isactive)
          SELECT node_stats.name,
                 node_stats.status,
                 node_stats.shard_count,
                 node_size.node_size
          FROM node_size,
               node_stats
          WHERE node_size.nodename = node_stats.name
          ORDER BY 2 DESC, 3 DESC;
        SQL
      end
    end
  end
end

