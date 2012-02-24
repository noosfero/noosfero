require "#{File.dirname(__FILE__)}/../test_helper"

class AssetsMenuTest < ActionController::IntegrationTest

  def setup
#    HomeController.any_instance.stubs(:get_layout).returns('application')
#    SearchController.any_instance.stubs(:get_layout).returns('application')

    parent = Category.create!(:name => "Parent Category", :environment => Environment.default, :display_color => 1)
    @category = Category.create!(:name => "Category A", :environment => Environment.default, :parent => parent)
  end
  
  should 'link to uncategorized assets at site root' do
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/search/contents' }
  end

  should 'link to assets inside category root' do
    ent = @category.enterprises.create! :identifier => 'ent1', :name => 'enterprise1'
    
    get '/cat/parent-category/category-a'
    assert_tag :tag => 'a', :attributes => { :href => '/search/enterprises/parent-category/category-a' }
  end

end
