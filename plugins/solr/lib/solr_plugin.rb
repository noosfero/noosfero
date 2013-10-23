class SolrPlugin < Noosfero::Plugin; end;

require_dependency 'solr_plugin/search_helper'

class SolrPlugin < Noosfero::Plugin

  include SolrPlugin::SearchHelper

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

  def stylesheet?
    true
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    klass = asset_class(asset)
    category = options.delete(:category)
    filter = options.delete(:filter)

    return if empty_query?(query, category) && klass != Product

    solr_options = solr_options(class_asset(klass), category)
    solr_options.merge!(products_options(user)) if klass == Product && empty_query?(query, category)
    klass.find_by_contents(query, paginate_options, solr_options.merge(options))
  end

  def method_missing method, *args, &block
    if self.context.respond_to? method
      self.context.send method, *args, &block
    else
      super method, *args, &block
    end
  end

end
