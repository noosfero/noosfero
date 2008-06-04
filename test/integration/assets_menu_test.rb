require "#{File.dirname(__FILE__)}/../test_helper"

class AssetsMenuTest < ActionController::IntegrationTest

  def setup
    parent = Category.create!(:name => "Parent Category", :environment => Environment.default, :display_color => 1)
    @category = Category.create!(:name => "Category A", :environment => Environment.default, :parent => parent)
  end
  
  should 'link to uncategorized assets at site root' do
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/assets/articles' }
  end

  should 'link to assets inside category root' do
    get '/cat/parent-category/category-a'
    assert_tag :tag => 'a', :attributes => { :href => '/assets/articles/parent-category/category-a' }
  end

  should 'link to other assets in same category when' do
    get '/assets/articles/parent-category/category-a'
    assert_tag :tag => 'a', :attributes => { :href => '/assets/products/parent-category/category-a' }
  end

end
