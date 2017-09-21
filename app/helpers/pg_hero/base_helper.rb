module PgHero
  module BaseHelper
    def pghero_pretty_ident(table, schema: nil)
      ident = table
      if schema && schema != "public"
        indent = "#{schema}.#{table}"
      end
      if ident =~ /\A[a-z0-9_]+\z/
        ident
      else
        @database.quote_ident(ident)
      end
    end

    def pghero_common_suffix(m)
      m = m.map { |s| s.reverse }
      # Given a array of strings, returns the longest common leading component
      return '' if m.empty?

      s1, s2 = m.min, m.max
      s1.each_char.with_index do |c, i|
        return s1[0...i].reverse if c != s2[i]
      end

      return s1.reverse
    end
  end
end
