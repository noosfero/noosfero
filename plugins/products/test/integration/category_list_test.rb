require_relative '../test_helper'


class CategoryListTest < ActionDispatch::IntegrationTest
  all_fixtures

	attr_accessor :person, :environment
	attr_reader :environment

	should 'display products categories when plugin is enabled' do
		@environment = Environment.default
    @environment.enable_plugin('ProductsPlugin')
    @environment.save!

    login 'ze', 'test'
		get "/admin/categories", :profile => 'ze'

		assert_tag :tag => 'a', :attributes => { :href =>	'/admin/categories/new?type=ProductCategory'}
	end

	should 'do not display products categories when plugin is disabled' do
		@environment = Environment.default
    @environment.disable_plugin('ProductsPlugin')
    @environment.save!
		login 'ze', 'test'
		get "/admin/categories", :profile => 'ze'

		assert_no_tag :tag => 'a', :attributes => { :href =>	'/admin/categories/new?type=ProductCategory'}
	end

	should 'list products categories correctely' do
		@environment = Environment.default
    @environment.enable_plugin('ProductsPlugin')
    @environment.save!

    @product_category = create ProductsPlugin::ProductCategory, name: 'Products'
    @product_category = create ProductsPlugin::ProductCategory, name: 'Test'

    login 'ze', 'test'
    get "/admin/categories", :profile => 'ze'

    assert_tag :tag => 'span', :content => 'Products'
    assert_tag :tag => 'span', :content => 'Test'
	end
end
