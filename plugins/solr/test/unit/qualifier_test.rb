require "#{File.dirname(__FILE__)}/../test_helper"

class QualifierTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex products after saving' do
    product = mock
    Qualifier.any_instance.stubs(:products).returns([product])
    Qualifier.expects(:solr_batch_add).with(includes(product))
    qual = fast_create(Qualifier)
    qual.save!
  end
end
