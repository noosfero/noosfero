require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex enterprise after saving' do
    ent = fast_create(Enterprise)
    cat = fast_create(ProductCategory)
    prod = Product.create!(:name => 'something', :enterprise_id => ent.id, :product_category_id => cat.id)
    Product.expects(:solr_batch_add).with([ent])
    prod.save!
  end
end

