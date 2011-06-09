module ActsAsFaceted

  module ClassMethods
  end

  module ActsMethods
    # Example:
    #
    # acts_as_faceted :fields => {
    #   :f_category => {:label => _('Related products')},
    #   :f_region => {:label => _('Region')},
    #   :f_qualifier => {:label => _('Qualifiers')}},
    #   :order => [:f_category, :f_region, :f_qualifier]
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

      def each_facet_name(solr_facet, data, options = {})
        facet = facets[solr_facet_fields[solr_facet]]

        if options[:sort] == :alphabetically
          result = data.sort{ |a,b| -1*(a[0] <=> b[0]) }
          result.each { |name, count| yield [name, count] }
        else
          result = options[:sort] == :count ? data.sort{ |a,b| -1*(a[1] <=> b[1]) } : data
          result.each { |name, count| yield [name, count] }
        end
      end
    end
  end

end

ActiveRecord::Base.extend ActsAsFaceted::ActsMethods

