require_relative '../../test_helper'

module ProductsPlugin
  class SearchControllerTest < ActionController::TestCase

    def setup
      @controller       = SearchController.new
      @product_category = create ProductCategory, name: 'prod cat test', environment: Environment.default
    end

    should 'include extra content supplied by plugins on product asset' do
      class Plugin1 < Noosfero::Plugin
        def asset_product_extras(product)
          proc {"<span id='plugin1'>This is Plugin1 speaking!</span>".html_safe}
        end
      end

      class Plugin2 < Noosfero::Plugin
        def asset_product_extras(product)
          proc {"<span id='plugin2'>This is Plugin2 speaking!</span>".html_safe}
        end
      end
      Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

      enterprise = fast_create(Enterprise)
      fast_create(Product, {profile_id: enterprise.id, name: "produto1", product_category_id: @product_category.id}, search: true)

      e = Environment.default
      e.enable_plugin(Plugin1.name)
      e.enable_plugin(Plugin2.name)

      get :products, query: 'produto1'

      assert_tag tag: 'span', content: 'This is Plugin1 speaking!', attributes: {id: 'plugin1'}
      assert_tag tag: 'span', content: 'This is Plugin2 speaking!', attributes: {id: 'plugin2'}
    end

    should 'search for products' do
      ent = create_profile_with_optional_category(Enterprise, 'teste')
      prod = ent.products.create!(name: 'a beautiful product', product_category: @product_category)
      get :products, query: 'beautiful'
      assert_includes assigns(:searches)[:products][:results], prod
    end

    should 'include extra properties of the product supplied by plugins' do
      class Plugin1 < Noosfero::Plugin
        def asset_product_properties(product)
          return { name: _('Property1'), content: proc { link_to(product.name, '/plugin1') } }
        end
      end
      class Plugin2 < Noosfero::Plugin
        def asset_product_properties(product)
          return { name: _('Property2'), content: proc { link_to(product.name, '/plugin2') } }
        end
      end
      Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])
      enterprise = fast_create(Enterprise)
      product = fast_create(Product, {profile_id: enterprise.id, name: "produto1", product_category_id: @product_category.id}, search: true)

      environment = Environment.default
      environment.enable_plugin(Plugin1.name)
      environment.enable_plugin(Plugin2.name)

      get :products, query: "produto1"

      assert_tag tag: 'div', content: /Property1/, child: {tag: 'a', attributes: {href: '/plugin1'}, content: product.name}
      assert_tag tag: 'div', content: /Property2/, child: {tag: 'a', attributes: {href: '/plugin2'}, content: product.name}
    end

    should 'render specific action when only one asset is enabled' do
      environment = Environment.default
      # article is not disabled
      [:enterprises, :people, :communities, :products, :events].select do |key, name|
        environment.enable('disable_asset_' + key.to_s)
      end
      environment.save!
      @controller.stubs(:environment).returns(environment)

      get :index, query: 'something'

      assert assigns(:searches).has_key?(:articles)
      refute assigns(:searches).has_key?(:enterprises)
      refute assigns(:searches).has_key?(:people)
      refute assigns(:searches).has_key?(:communities)
      refute assigns(:searches).has_key?(:products)
      refute assigns(:searches).has_key?(:events)
    end

    should 'display only within a product category when specified' do
      ent = create_profile_with_optional_category(Enterprise, 'test ent')

      p = create(Product, product_category: @product_category, name: 'prod test 1', enterprise: ent)

      get :products, product_category: @product_category.id

      assert_includes assigns(:searches)[:products][:results], p
    end

    should 'display properly in conjuntion with a category' do
      cat = create(Category, name: 'cat', environment: Environment.default)
      prod_cat2 = create ProductCategory, name: 'prod cat test 2', environment: Environment.default, parent: @product_category1
      ent = create_profile_with_optional_category(Enterprise, 'test ent', cat)

      product = create(Product, product_category: prod_cat2, name: 'prod test 1', profile_id: ent.id)

      get :products, category_path: cat.path.split('/'), product_category: @product_category.id

      assert_includes assigns(:searches)[:products][:results], product
    end

    should 'find products when enterprises has own hostname' do
      ent = create_profile_with_optional_category(Enterprise, 'teste')
      ent.domains << Domain.new(name: 'testent.com'); ent.save!
      prod = ent.products.create!(name: 'a beautiful product', product_category: @product_category)
      get 'products', query: 'beautiful'
      assert_includes assigns(:searches)[:products][:results], prod
    end

    should 'add script tag for google maps if searching products' do
      get 'products', query: 'product', display: 'map'

      assert_tag tag: 'script', attributes: { src: 'https://maps.google.com/maps/api/js?sensor=true'}
    end

    should 'add highlighted CSS class around a highlighted product' do
      enterprise = fast_create(Enterprise)
      product = create(Product, name: 'Enter Sandman', profile_id: enterprise.id, product_category_id: @product_category.id, highlighted: true)
      get :products
      assert_tag tag: 'li', attributes: { class: 'search-product-item highlighted' }, content: /Enter Sandman/
    end

    should 'do not add highlighted CSS class around an ordinary product' do
      enterprise = fast_create(Enterprise)
      product = create(Product, name: 'Holier Than Thou', profile_id: enterprise.id, product_category_id: @product_category.id, highlighted: false)
      get :products
      assert_no_tag tag: 'li', attributes: { class: 'search-product-item highlighted' }, content: /Holier Than Thou/
    end

    protected

    def create_profile_with_optional_category klass, name, category = nil, data = {}
      fast_create klass, { name: name }.merge(data), search: true, category: category
    end

  end
end
