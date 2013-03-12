require_dependency 'search_controller'

module SolrPlugin::FacetsBrowse
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, SolrPlugin::SearchHelper
  end

  module InstanceMethods
    def facets_browse
      @asset = params[:asset_key].to_sym
      @asset_class = asset_class(@asset)

      @facets_only = true
      send(@asset)
      set_facets_variables

      @facet = @asset_class.map_facets_for(environment).find { |facet| facet[:id] == params[:facet_id] }
      raise 'Facet not found' if @facet.nil?

      render :layout => false
    end
  end
end

SearchController.send(:include, SolrPlugin::FacetsBrowse)
