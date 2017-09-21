module PgHero
  module Methods
    module Settings
      def settings
        names =
          if server_version_num >= 90500
            %i(
              max_connections shared_buffers effective_cache_size work_mem
              maintenance_work_mem min_wal_size max_wal_size checkpoint_completion_target
              wal_buffers default_statistics_target
            )
          else
            %i(
              max_connections shared_buffers effective_cache_size work_mem
              maintenance_work_mem checkpoint_segments checkpoint_completion_target
              wal_buffers default_statistics_target
            )
          end
        fetch_settings(names)
      end

      def citus_settings
        names =
            %i(
                  citus.count_distinct_error_rate
                  citus.distributed_deadlock_detection_factor
                  citus.explain_all_tasks
                  citus.limit_clause_row_fetch_count
                  citus.max_assign_task_batch_size
                  citus.max_running_tasks_per_node
                  citus.multi_shard_commit_protocol
                  citus.node_connection_timeout
                  citus.shard_count
                  citus.shard_placement_policy
                  citus.subquery_pushdown
                  citus.task_assignment_policy
                  citus.version
            )

        fetch_settings(names)
      end

      def autovacuum_settings
        fetch_settings %i(autovacuum autovacuum_max_workers autovacuum_vacuum_cost_limit autovacuum_vacuum_scale_factor autovacuum_analyze_scale_factor)
      end

      def vacuum_settings
        fetch_settings %i(vacuum_cost_limit)
      end

      private

      def fetch_settings(names)
        Hash[names.map { |name| [name, select_one("SHOW #{name}")] }]
      end

    end
  end
end
