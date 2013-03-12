class SolrPlugin < Noosfero::Plugin; end;

require_dependency 'solr_plugin/search_helper'

class SolrPlugin < Noosfero::Plugin

  include SolrPlugin::SearchHelper

  delegate :params, :current_user, :to => :context

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

  def stylesheet?
    true
  end

  def find_by_contents(klass, query, paginate_options={}, options={})
    category = options.delete(:category)
    filter = options.delete(:filter)
    solr_options = solr_options(class_asset(klass), category)
    user = context.respond_to?(:user) ? context.send(:user) : nil
    solr_options.merge!(products_options(user)) if klass == Product && empty_query?(query, category)
    klass.find_by_contents(query, paginate_options, solr_options.merge(options))
  end

end

Dir[File.join(SolrPlugin.root_path, 'lib', 'ext', '*.rb')].each {|file| require_dependency file }
