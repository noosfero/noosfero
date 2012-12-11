require 'test_helper'

class EnterpriseTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @product_category = fast_create(ProductCategory)
  end

  attr_accessor :environment, :product_category

  should 'reindex when products are changed' do
    enterprise = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => enterprise.id, :product_category_id => product_category.id)
    Product.expects(:solr_batch_add_association).with(product, :enterprise)
    product.update_attribute :name, "novo nome"
  end
end
