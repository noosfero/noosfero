module ActsAsFaceted

  module ClassMethods
  end

  module ActsMethods
    # Example:
    #
    #acts_as_faceted :fields => {
    #  :f_type => {:label => _('Type'), :proc => proc{|klass| f_type_proc(klass)}},
    #  :f_published_at => {:type => :date, :label => _('Published date'), :queries => {'[* TO NOW-1YEARS/DAY]' => _("Older than one year"),
    #    '[NOW-1YEARS TO NOW/DAY]' => _("Last year"), '[NOW-1MONTHS TO NOW/DAY]' => _("Last month"), '[NOW-7DAYS TO NOW/DAY]' => _("Last week"), '[NOW-1DAYS TO NOW/DAY]' => _("Last day")}},
    #  :f_profile_type => {:label => _('Author'), :proc => proc{|klass| f_profile_type_proc(klass)}},
    #  :f_category => {:label => _('Categories')}},
    #  :order => [:f_type, :f_published_at, :f_profile_type, :f_category]
    #
    #acts_as_searchable :additional_fields => [ {:name => {:type => :string, :as => :name_sort, :boost => 5.0}} ] + facets_fields_for_solr,
    #  :exclude_fields => [:setting],
    #  :include => [:profile],
    #  :facets => facets_option_for_solr,
    #  :if => proc{|a| ! ['RssFeed'].include?(a.class.name)}
    def acts_as_faceted(options)
      extend ClassMethods
      extend ActsAsSolr::CommonMethods

      cattr_accessor :facets
      cattr_accessor :facets_order
      cattr_accessor :to_solr_fields_names
      cattr_accessor :facets_results_containers
      cattr_accessor :solr_fields_names
      cattr_accessor :facets_option_for_solr
      cattr_accessor :facets_fields_for_solr
      cattr_accessor :facet_category_query

      self.facets = options[:fields]
      self.facets_order = options[:order] || self.facets.keys
      self.facets_results_containers = {:fields => 'facet_fields', :queries => 'facet_queries', :ranges => 'facet_ranges'}
      self.facets_option_for_solr = Hash[facets.select{ |id,data| ! data.has_key?(:queries) }].keys
      self.facets_fields_for_solr = facets.map{ |id,data| {id => data[:type] || :facet} }
      self.solr_fields_names = facets.map{ |id,data| id.to_s + '_' + get_solr_field_type(data[:type] || :facet) }
      self.facet_category_query = options[:category_query]

      # A hash to retrieve the field key for the solr facet string returned
      # :field_name => "field_name_facet"
      self.to_solr_fields_names = Hash[facets.keys.zip(solr_fields_names)]

      def facet_by_id(id)
        {:id => id}.merge(facets[id]) if facets[id]
      end

      def map_facets_for(environment)
        facets_order.map do |id|
          facet = facet_by_id(id)
          next if facet[:type_if] and !facet[:type_if].call(self.new)

          if facet[:multi]
            facet[:label].call(environment).map do |label_id, label|
              facet.merge({:id => facet[:id].to_s+'_'+label_id.to_s, :solr_field => facet[:id], :label_id => label_id, :label => label})
            end
          else
            facet.merge(:id => facet[:id].to_s, :solr_field => facet[:id])
          end
        end.compact.flatten
      end

      def map_facet_results(facet, facet_params, facets_data, unfiltered_facets_data = {}, options = {})
        raise 'Use map_facets_for before this method' if facet[:solr_field].nil?
        facets_data = {} if facets_data.blank? # could be empty array
        solr_facet = to_solr_fields_names[facet[:solr_field]]
        unfiltered_facets_data ||= {}

        if facet[:queries]
          container = facets_data[facets_results_containers[:queries]]
          facet_data = (container.nil? or container.empty?) ? [] : container.select{ |k,v| k.starts_with? solr_facet }
          container = unfiltered_facets_data[facets_results_containers[:queries]]
          unfiltered_facet_data = (container.nil? or container.empty?) ? [] : container.select{ |k,v| k.starts_with? solr_facet }
        else
          container = facets_data[facets_results_containers[:fields]]
          facet_data = (container.nil? or container.empty?) ? [] : container[solr_facet] || []
          container = unfiltered_facets_data[facets_results_containers[:fields]]
          unfiltered_facet_data = (container.nil? or container.empty?) ? [] : container[solr_facet] || []
        end

        if !unfiltered_facets_data.blank? and !facet_params.blank?
          f = Hash[Array(facet_data)]
          zeros = []
          facet_data = unfiltered_facet_data.map do |id, count|
            count = f[id]
            if count.nil?
              zeros.push [id, 0]
              nil
            else
              [id, count]
            end
          end.compact + zeros
        end

        facet_count = facet_data.length

        if facet[:queries]
          result = facet_data.map do |id, count|
            q = id[id.index(':')+1,id.length]
            label = facet_result_name(facet, q)
            [q, label, count] if count > 0
          end.compact
          result = facet[:queries_order].map{ |id| result.detect{ |rid, label, count| rid == id } }.compact if facet[:queries_order]
        elsif facet[:proc]
          if facet[:label_id]
            result = facet_data.map do |id, count|
              name = facet_result_name(facet, id)
              [id, name, count] if name
            end.compact
            # FIXME limit is NOT improving performance in this case :(
            facet_count = result.length
            result = result.first(options[:limit]) if options[:limit]
          else
            facet_data = facet_data.first(options[:limit]) if options[:limit]
            result = facet_data.map { |id, count| [id, facet_result_name(facet, id), count] }
          end
        else
          facet_data = facet_data.first(options[:limit]) if options[:limit]
          result = facet_data.map { |id, count| [id, facet_result_name(facet, id), count] }
        end

        sorted = facet_result_sort(facet, result, options[:sort])

        # length can't be used if limit option is given;
        # total_entries comes to help
        sorted.class.send(:define_method, :total_entries, proc { facet_count })

        sorted
      end

      def facet_result_sort(facet, facets_data, sort_by = nil)
        if facet[:queries_order]
          facets_data
        elsif sort_by == :alphabetically
          facets_data.sort{ |a,b| Array(a[1])[0] <=> Array(b[1])[0] }
        elsif sort_by == :count
          facets_data.sort{ |a,b| -1*(a[2] <=> b[2]) }
        else
          facets_data
        end
      end

      def facet_result_name(facet, data)
        if facet[:queries]
          gettext(facet[:queries][data])
        elsif facet[:proc]
          if facet[:multi]
            facet[:label_id] ||= 0
            facet[:proc].call(facet, data)
          else
            gettext(facet[:proc].call(data))
          end
        else
          data
        end
      end

      def facet_label(facet)
        return nil unless facet
        _(facet[:label])
      end

      def facets_find_options(facets_selected = {}, options = {})
        browses = []
        facets_selected ||= {}
        facets_selected.map do |id, value|
          next unless facets[id.to_sym]
          if value.kind_of?(Hash)
            value.map do |label_id, value|
              value.to_a.each do |value|
                browses << id.to_s + ':' + (facets[id.to_sym][:queries] ? value : '"'+value.to_s+'"')
              end
            end
          else
            browses << id.to_s + ':' + (facets[id.to_sym][:queries] ? value : '"'+value.to_s+'"')
          end
        end.flatten

        {:facets => {:zeros => false, :sort => :count,
            :fields => facets_option_for_solr,
            :browse => browses,
            :query => facets.map { |f, options| options[:queries].keys.map { |q| f.to_s + ':' + q } if options[:queries] }.compact.flatten,
          }
        }
      end
    end
  end

end

ActiveRecord::Base.extend ActsAsFaceted::ActsMethods

# from https://github.com/rubyworks/facets/blob/master/lib/core/facets/enumerable/graph.rb
module Enumerable
  def graph(&yld)
    if yld
      h = {}
      each do |*kv|
        r = yld[*kv]
        case r
        when Hash
          nk, nv = *r.to_a[0]
        when Range
          nk, nv = r.first, r.last
        else
          nk, nv = *r
        end
        h[nk] = nv
      end
      h
    else
      Enumerator.new(self,:graph)
    end
  end

  # Alias for #graph, which stands for "map hash".
  alias_method :mash, :graph
end

