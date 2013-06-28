require "#{File.dirname(__FILE__)}/../test_helper"

class CertifierTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex products after saving' do
    product = mock
    Certifier.any_instance.stubs(:products).returns([product])
    Certifier.expects(:solr_batch_add).with(includes(product))
    cert = fast_create(Certifier)
    cert.save!
  end
end

