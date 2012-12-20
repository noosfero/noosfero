require_dependency 'solr_plugin/search_helper'

class SolrPlugin < Noosfero::Plugin

  include SolrPlugin::SearchHelper

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

  def search_engine?
    true
  end

  def full_text_search(asset, query, category, paginate_options)
    asset_class = asset_class(asset)
    solr_options = solr_options(asset, category)
    asset_class.find_by_contents(query, paginate_options, solr_options)
  end

end

Dir[File.join(SolrPlugin.root_path, 'lib', 'ext', '*.rb')].each {|file| require_dependency file }
