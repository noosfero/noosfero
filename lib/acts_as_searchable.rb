module ActsAsSearchable

  module ClassMethods
    ACTS_AS_SEARCHABLE_ENABLED = true unless defined? ACTS_AS_SEARCHABLE_ENABLED

    def acts_as_searchable(options = {})
      if ACTS_AS_SEARCHABLE_ENABLED
        if (!options[:fields])
          options[:additional_fields] |= [{:schema_name => :string}]
        else
          options[:fields] << {:schema_name => :string}
        end
        acts_as_solr options
        extend FindByContents
        send :include, InstanceMethods
      end
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
        options[:limit] = 1000000;
        options[:scores] = true;

        query = !schema_name.empty? ? "+schema_name:\"#{schema_name}\" AND #{query}" : query
        solr_result = find_by_solr(query, options)
        if solr_result.nil?
          results = facets = []
        else
          facets = options.include?(:facets) ? solr_result.facets : {}
          if db_options.empty?
            results = solr_result.results
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

            results = find(:all, db_options)
          end
        end

        if !pg_options.empty?
            pg_options[:page] ||= 1
            results = results.paginate(pg_options)
        end
        {:results => results, :facets => facets}
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActsAsSearchable::ClassMethods)
