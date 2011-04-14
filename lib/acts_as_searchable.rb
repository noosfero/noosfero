module ActsAsSearchable

  module ClassMethods
    def acts_as_searchable(options = {})
      if (!options[:fields])
        options[:additional_fields] |= [{:schema_name => :string}]
      else
        options[:fields] << {:schema_name => :string}
      end
      acts_as_solr options
      extend FindByContents
      send :include, InstanceMethods
    end

    module InstanceMethods
      def schema_name
        (Noosfero::MultiTenancy.on? and ActiveRecord::Base.postgresql?) ? ActiveRecord::Base.connection.schema_search_path : ''
      end
    end

    module FindByContents

      def schema_name
        (Noosfero::MultiTenancy.on? and ActiveRecord::Base.postgresql?) ? ActiveRecord::Base.connection.schema_search_path : ''
      end

      def find_by_contents(query, pg_options = {}, options = {}, db_options = {})
        pg_options[:page] ||= 1
        options[:limit] = 1000000;
        options[:scores] = true;

        query = !schema_name.empty? ? "+schema_name:\"#{schema_name}\" AND #{query}" : query
        solr_result = find_by_solr(query, options)
        if solr_result.nil?
          results = facets = []
        else
          facets = options.include?(:facets) ? solr_result.facets : {}
          if db_options.empty?
            results = solr_result.results.paginate(pg_options)
          else
            ids = solr_result.results.map{|r|r[:id].to_i}
            if ids.empty?
              ids << -1
            end

            if db_options[:conditions]
              db_options[:conditions] = sanitize_sql_for_conditions(db_options[:conditions]) + " and #{table_name}.id in (#{ids.join(', ')})"
            else
              db_options[:conditions] = "#{table_name}.id in (#{ids.join(', ')})"
            end

            result = find(:all, db_options)
            results = result.paginate(pg_options)
          end
        end

        {:results => results, :facets => facets}
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActsAsSearchable::ClassMethods)
