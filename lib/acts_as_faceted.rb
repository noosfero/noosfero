module ActsAsFaceted

  module ClassMethods
  end

  module ActsMethods
    # === fields:
    # A hash of id fields (may be an attribute or a method).
    # === order:
    # An array
    # Example:
    #
    # acts_as_faceted :fields => {:f_category_id => {:class => ProductCategory, :display_field => :name, :label => _('Related products')},
    #  :f_region_id => {:class => Region, :display_field => :name, :label => _('Region')},
    #  :f_qualifier_id => {:class => Qualifier, :display_field => :name, :label => _('Qualifiers')},
    #  :f_certifier_id => {:class => Certifier, :display_field => :name, :label => _('Certifiers')}},
    #  :order => [:f_category_id, :f_region_id, :f_qualifier_id, :f_certifier_id]
    # end
    def acts_as_faceted(options)
      extend ClassMethods

      cattr_accessor :facets
      cattr_accessor :facets_order
      cattr_accessor :solr_facet_fields
      cattr_accessor :to_solr_facet_fields

      self.facets = options[:fields]
      self.facets_order = options[:order] || facets

      # A hash to retrieve the field key for the solr facet string returned
      # "field_name_facet" => :field_name
      self.solr_facet_fields = Hash[facets.keys.map{|f| f.to_s+'_facet'}.zip(facets.keys)]
      # :field_name => "field_name_facet"
      self.to_solr_facet_fields = Hash[facets.keys.zip(facets.keys.map{|f| f.to_s+'_facet'})]

      def each_facet
        if facets_order
          facets_order.each_with_index { |f, i| yield [f, i] }
        else
          facets.each_with_index { |f, i| yield [f. i] }
        end
      end

      def each_facet_obj(solr_facet, id_hash, options = {})
        facet = facets[solr_facet_fields[solr_facet]]
        klass = facet[:class]

        if options[:sort] == :alphabetically
          display_field = facet[:display_field]
          result = []
          id_hash.each do |id, count|
            obj = klass.find_by_id(id)
            result << [obj, count] if obj
          end
          result = result.sort { |a,b| a[0].send(display_field) <=> b[0].send(display_field) }
          result.each { |obj, count| yield [obj, count] }
        else
          result = options[:sort] == :count ? id_hash.sort{ |a,b| -1*(a[1] <=> b[1]) } : id_hash
          result.each do |id, count|
            obj = klass.find_by_id(id)
            yield [obj, count] if obj
          end
        end
      end
    end
  end

end

ActiveRecord::Base.extend ActsAsFaceted::ActsMethods

