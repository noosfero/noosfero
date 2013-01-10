# TODO This controller was created to remove the solr dependencies from
# noosfero controllers. All actions here might not be working as they're
# supposed to. Everything here must be reviewed!

class SolrPluginPublicController < MyProfileController

  include SolrPlugin::ResultsHelper


  def facets_browse
    @asset = params[:asset].to_sym
    @asset_class = asset_class(@asset)

    @facets_only = true
    send(@asset)

    @facet = @asset_class.map_facets_for(environment).find { |facet| facet[:id] == params[:facet_id] }
    raise 'Facet not found' if @facet.nil?

    render :layout => false
  end
end
