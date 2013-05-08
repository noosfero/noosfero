require "#{File.dirname(__FILE__)}/../test_helper"

class ProductCategoryTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex products after save' do
    product = mock
    ProductCategory.any_instance.stubs(:products).returns([product])
    ProductCategory.expects(:solr_batch_add).with(includes(product))
    pc = fast_create(ProductCategory)
    pc.save!
  end
end

