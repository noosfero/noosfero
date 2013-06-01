module ActsAsSearchable

  module ClassMethods
    ACTS_AS_SEARCHABLE_ENABLED = true unless defined? ACTS_AS_SEARCHABLE_ENABLED

    def acts_as_searchable(options = {})
      return if !ACTS_AS_SEARCHABLE_ENABLED

      if options[:fields]
        options[:fields] << {:schema_name => :string}
      else
        options[:additional_fields] ||= []
        options[:additional_fields] << {:schema_name => :string}
      end

      acts_as_solr options
      extend FindByContents
      send :include, InstanceMethods
    end

    module InstanceMethods
      def schema_name
        self.class.schema_name
      end

      # replace solr_id from vendor/plugins/acts_as_solr_reloaded/lib/acts_as_solr/instance_methods.rb
      # to include schema_name
      def solr_id
         id = "#{self.class.name}:#{record_id(self)}"
         id.insert(0, "#{schema_name}:") unless schema_name.blank?
         id
      end
    end

    module FindByContents

      def schema_name
        (Noosfero::MultiTenancy.on? and ActiveRecord::Base.postgresql?) ? ActiveRecord::Base.connection.schema_search_path : ''
      end

      def find_by_contents(query, pg_options = {}, options = {}, db_options = {})
        pg_options[:page] ||= 1
        pg_options[:per_page] ||= 20
        options[:page] = pg_options[:page].to_i
        options[:per_page] = pg_options[:per_page].to_i
        options[:scores] ||= true
        options[:filter_queries] ||= []
        options[:filter_queries] << "schema_name:\"#{schema_name}\"" unless schema_name.blank?
        all_facets_enabled = options.delete(:all_facets)
        options[:per_page] = options.delete(:extra_limit) if options[:extra_limit]
        results = []
        facets = all_facets = {}

        solr_result = find_by_solr(query, options)
        if all_facets_enabled
          options[:facets][:browse] = nil
          all_facets = find_by_solr(query, options.merge(:per_page => 0)).facets
        end

        if !solr_result.nil?
          facets = options.include?(:facets) ? solr_result.facets : []

          if db_options.empty?
            results = solr_result
          else
            ids = solr_result.results.map{ |r| r[:id].to_i }
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

        {:results => results, :facets => facets, :all_facets => all_facets}
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActsAsSearchable::ClassMethods)
