require "#{File.dirname(__FILE__)}/../test_helper"

class CategoriesMenuTest < ActionController::IntegrationTest

  def setup
    Category.delete_all
    @cat1 = Category.create!(:display_in_menu => true, :name => 'Food', :environment => Environment.default, :display_color => 1)
    @cat2 = Category.create!(:display_in_menu => true, :name => 'Vegetables', :environment => Environment.default, :parent => @cat1)

    # all categories must be shown for these tests 
    Category.any_instance.stubs(:display_in_menu?).returns(true)
  end

  should 'display link to categories' do
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/cat/food/vegetables' }
  end

  should 'display link to sub-categories' do
    get '/cat/food'
    # there must be a link to the subcategory
    assert_tag :tag => 'a', :attributes => { :href => '/cat/food/vegetables' }
  end

  should 'link to other assets in the same category when viewing an asset' do
    get '/assets/articles/food/vegetables'
    assert_no_tag :tag => 'a', :attributes => { :href => '/cat/food/vegetables' }
    assert_tag :tag => 'a', :attributes => { :href => '/assets/enterprises/food/vegetables' }
  end

end
