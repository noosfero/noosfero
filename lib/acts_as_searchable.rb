module ActsAsSearchable

  module ClassMethods
    ACTS_AS_SEARCHABLE_ENABLED = true unless defined? ACTS_AS_SEARCHABLE_ENABLED

    def acts_as_searchable(options = {})
      return if !ACTS_AS_SEARCHABLE_ENABLED

      if (!options[:fields])
        options[:additional_fields] |= [{:schema_name => :string}]
      else
        options[:fields] << {:schema_name => :string}
      end
      acts_as_solr options
      extend FindByContents
      send :include, InstanceMethods

      handle_asynchronously :solr_save
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
        pg_options[:per_page] ||= 20
        options[:limit] ||= pg_options[:per_page].to_i*pg_options[:page].to_i
        options[:scores] ||= true;
        all_facets_enabled = options.delete(:all_facets)
        query = !schema_name.empty? ? "+schema_name:\"#{schema_name}\" AND #{query}" : query
        results = []
        facets = all_facets = {}

        solr_result = find_by_solr(query, options)
        if all_facets_enabled
          options[:facets][:browse] = nil
          all_facets = find_by_solr(query, options.merge(:limit => 0)).facets
        end
        
        if !solr_result.nil?
          facets = options.include?(:facets) ? solr_result.facets : []

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

          results = results.paginate(pg_options.merge(:total_entries => solr_result.total))
        end

        {:results => results, :facets => facets, :all_facets => all_facets}
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActsAsSearchable::ClassMethods)
