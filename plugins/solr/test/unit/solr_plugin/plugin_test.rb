require_relative "../../test_helper"

class SolrPlugin::PluginTest < ActiveSupport::TestCase
  def setup
    @plugin = SolrPlugin.new
  end
  attr_reader :plugin

  should "convert scopes to solr filters" do
    person = create_user("test").person
    result = plugin.send :scopes_to_solr_filters, person.files.published
    assert_equal result, ["profile_id:#{person.id}", "published:'true'"]
  end
end
