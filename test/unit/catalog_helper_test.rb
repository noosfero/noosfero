require_relative "../test_helper"

class CatalogHelperTest < ActiveSupport::TestCase

  include CatalogHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionDispatch::Assertions::SelectorAssertions

  def url_for(opts)
    #{:controller => 'catalog', :action => 'index', :level => category.id}
    "#{opts[:controller]}-#{opts[:action]}-level=#{opts[:level]}"
  end

  def new_productcategory(parent, name)
    cat = ProductCategory.new(
      :name => name, :environment => Environment.default, :parent => parent
    )
    cat if cat.save
  end

  def setup
    @enterprise = Enterprise.create! :name => 'Test Enterprise',
                                     :identifier => 'testenterprise',
                                     :environment => Environment.default
    @profile = @enterprise
    @block = @enterprise.blocks.select{|b| b.class == ProductCategoriesBlock }[0]
    @products   = new_productcategory nil,         'Products'
    @food       = new_productcategory @products,   'Food'
    @vegetables = new_productcategory @food,       'Vegetables'
    @beans      = new_productcategory @vegetables, 'Beans'
    @rice       = new_productcategory @vegetables, 'Rice'
    @mineral    = new_productcategory @products,   'Mineral'
    @iron       = new_productcategory @mineral,    'Iron'
    @gold       = new_productcategory @mineral,    'Gold'
  end
  attr_accessor :profile

  should 'list product category sub-list' do
    @enterprise.products.create!(:name => 'Gold Ring', :product_category => @gold)
    @enterprise.products.create!(:name => 'Uncle Jon Beans', :product_category => @beans)
    @enterprise.products.create!(:name => 'Red Rice', :product_category => @rice)

    html = category_with_sub_list @products

    doc = HTML::Document.new "<body>#{html}</body>"
    assert_select doc.root, 'div' do |divs|
      assert_select divs[0], "a[href=catalog-index-level=#{@products.id}]"
      assert_select divs[0], '.count', {:text=>'3'}
      assert_select divs[1], "a[href=catalog-index-level=#{@food.id}]"
      assert_select divs[1], '.count', {:text=>'2'}
      assert_select divs[2], "a[href=catalog-index-level=#{@mineral.id}]"
      assert_select divs[2], '.count', {:text=>'1'}
    end
  end

end
