require_relative '../test_helper'


class CategoryListTest < ActionDispatch::IntegrationTest
  all_fixtures

	attr_accessor :person, :environment
	attr_reader :environment

  def setup
		@environment = Environment.default
    @environment.enable_plugin('ProductsPlugin')
    @environment.save!

    @environment.add_admin Profile['ze']
  end

	should 'display products categories when plugin is enabled' do
    login 'ze', 'test'
		get "/admin/categories", :profile => 'ze'

		assert_tag :tag => 'a', :attributes => { :href =>	'/admin/categories/new?type=ProductCategory'}
	end

	should 'do not display products categories when plugin is disabled' do
    @environment.disable_plugin('ProductsPlugin')
		login 'ze', 'test'
		get "/admin/categories", :profile => 'ze'

		assert_no_tag :tag => 'a', :attributes => { :href =>	'/admin/categories/new?type=ProductCategory'}
	end

	should 'list products categories correctely' do
    @product_category = create ProductsPlugin::ProductCategory, name: 'Products'
    @product_category = create ProductsPlugin::ProductCategory, name: 'Test'

    login 'ze', 'test'
    get "/admin/categories", :profile => 'ze'

    assert_tag :tag => 'span', :content => 'Products'
    assert_tag :tag => 'span', :content => 'Test'
	end
end
