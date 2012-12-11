class SolrPlugin < Noosfero::Plugin

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

end

Dir[File.join(SolrPlugin.root_path, 'lib', 'ext', '*.rb')].each {|file| require_dependency file }
