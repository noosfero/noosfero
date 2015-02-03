require_relative "../test_helper"

class FeaturedProductsBlockTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
    @environment = Environment.default
    @environment.boxes << Box.new
  end
  attr_reader :profile

  should 'refer to products' do
    profile = fast_create(Enterprise)
    products = []
    category = fast_create(ProductCategory)
    3.times {|n| products.push(create(Product, :name => "product #{n}", :profile_id => profile.id, :product_category_id => category.id)) }
    featured_products_block = create(FeaturedProductsBlock, :product_ids => products.map(&:id))
    assert_equal products, featured_products_block.products
  end

  should "have method products_for_selection" do
    block = FeaturedProductsBlock.new
    assert_respond_to block, 'products_for_selection'
  end

  should " the defaul product_ids be an empty array" do
    block = FeaturedProductsBlock.new
    assert_equal [], block.product_ids
  end

  should " the defaul groups_of be 3" do
    block = FeaturedProductsBlock.new
    assert_equal 3, block.groups_of
  end

  should 'default interval between transitions is 1000 miliseconds' do
    block = FeaturedProductsBlock.new
    assert_equal 1000, block.speed
  end

  should "reflect by default" do
    block = FeaturedProductsBlock.new
    assert_equal true, block.reflect
  end

  should 'describe itself' do
    assert_not_equal Block.description, FeaturedProductsBlock.description
  end

  should "the groups_of variabe be a integer" do
    block = FeaturedProductsBlock.new
    assert_kind_of Integer, block.groups_of
    block.groups_of = 2
    block.save
    block.reload
    assert_kind_of Integer, block.groups_of
    block.groups_of = '2'
    block.save
    block.reload
    assert_kind_of Integer, block.groups_of
  end

  should "an environment block collect product automatically" do
    block = build(FeaturedProductsBlock, )
    block.product_ids = []
    enterprise = create(Enterprise, :name => "My enterprise", :identifier => 'myenterprise', :environment => @environment)
    category = fast_create(ProductCategory)
    3.times {|n|
      create(Product, :name => "product #{n}", :profile_id => enterprise.id,
        :highlighted => true, :product_category_id => category.id,
        :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') }
      )
    }
    @environment.boxes.first.blocks<< block

    assert_not_equal [], block.product_ids
  end

  should "an environment block collect just product with image automatically" do
    block = build(FeaturedProductsBlock, )
    block.product_ids = []
    enterprise = create(Enterprise, :name => "My enterprise", :identifier => 'myenterprise', :environment => @environment)
    category = fast_create(ProductCategory)
    3.times {|n|
      create(Product, :name => "product #{n}", :profile_id => enterprise.id, :highlighted => true, :product_category_id => category.id)
    }
    @environment.boxes.first.blocks<< block

    assert_equal [], block.product_ids
  end

  should "an environment block collect just highlighted product automatically" do
    block = build(FeaturedProductsBlock, )
    block.product_ids = []
    enterprise = create(Enterprise, :name => "My enterprise", :identifier => 'myenterprise', :environment => @environment)
    category = fast_create(ProductCategory)
    3.times {|n|
      create(Product, :name => "product #{n}", :profile_id => enterprise.id, :product_category_id => category.id, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
    }
    @environment.boxes.first.blocks<< block

    assert_equal [], block.product_ids
  end

  should 'display feature products block' do
    block = FeaturedProductsBlock.new

    self.expects(:render).with(:file => 'blocks/featured_products', :locals => { :block => block})
    instance_eval(& block.content)
  end

  should "return just highlighted products with image for selection" do
    block = build(FeaturedProductsBlock, )
    block.product_ids = []
    enterprise = create(Enterprise, :name => "My enterprise", :identifier => 'myenterprise', :environment => @environment)
    category = fast_create(ProductCategory)
    products = []
    3.times {|n|
      products.push(create(Product, :name => "product #{n}", :profile_id => enterprise.id,
        :highlighted => true, :product_category_id => category.id,
        :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') }
      ))
    }
    create(Product, :name => "product 4", :profile_id => enterprise.id, :product_category_id => category.id, :highlighted => true)
    create(Product, :name => "product 5", :profile_id => enterprise.id, :product_category_id => category.id, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
    @environment.boxes.first.blocks<< block

    products_for_selection = block.products_for_selection

    products.each do |product|
      assert_includes products_for_selection, product
    end
  end

end
