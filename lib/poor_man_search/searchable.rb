module PoorManSearch
  module Searchable
    def string_search *fields
      @string_fields = fields
    end

    def number_search *fields
      @number_fields = fields
    end

    def time_search *fields
      @time_fields = fields
    end

    def time_range *fields
      @time_fields = fields
    end

    def search key_words_string
      criteria = Criteria.new key_words_string
      t = self.arel_table

      search_scope = scoped
      clauses = string_clauses(t, criteria)
      clauses << number_clause(t, criteria)
      clauses << time_clause(t, criteria)

      clauses.compact.each{|clause|
        search_scope = search_scope.where(clause)
      }
      search_scope
    end

    def associative_search key_words_string, *associations
      ids = search(key_words_string).select("#{self.table_name}.id")
      ids += associations.collect{|as|
        scoped.includes(as).merge(asociation_class(as).search(key_words_string)).select("#{self.table_name}.id")
      }.flatten
      where(:id => ids.uniq)
    end

    private

    def asociation_class as_sym
      _as = as_sym
      while(_as.is_a? Hash) do
        _as = _as.values.first
      end
      _as.to_s.singularize.classify.constantize
    end

    def string_clauses(t, criteria)
      return [] if @string_fields.blank?
      criteria.strings.collect do |word|
        v = "%#{word}%"
        clause = nil

        @string_fields.collect{|f|
          t[f].matches(v)
        }.each{|t_node|
          clause = clause.or(t_node) rescue t_node
        }
        clause
      end
    end

    def number_clause(t, criteria)
      return nil if @number_fields.blank?
      clause = nil
      criteria.numbers.collect do |value|
        @number_fields.collect{|f|
          t[f].eq(value)
        }.each{|t_node|
          clause = clause.or(t_node) rescue t_node
        }
      end
      clause
    end

    def time_clause(t, criteria)
      return nil if @time_fields.blank?
      clause = nil
      criteria.times.each do |value|
        @time_fields.each{|f|
          find_by_time(t, value).each{|t_node|
            clause = clause.or(t_node) rescue t_node
          }
        }
      end
      clause
    end

    def find_by_time(table, time)
      return fetch_from_time_range(table, time, time+59.seconds) if (time.hour > 0 && time.min > 0)
      return fetch_from_time_range(table, time.beginning_of_hour, time.end_of_hour) if (time.hour > 0)
      return fetch_from_time_range(table, time.beginning_of_day, time.end_of_day)
    end

    def fetch_from_time_range(table, start_time, end_time)
      @time_fields.collect{|f|
        table[f].gteq(start_time).and(table[f].lteq(end_time))
      }
    end
  end
end
