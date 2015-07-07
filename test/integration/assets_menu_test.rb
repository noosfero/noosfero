require_relative "../test_helper"

class AssetsMenuTest < ActionDispatch::IntegrationTest

  def setup
#    HomeController.any_instance.stubs(:get_layout).returns('application')
#    SearchController.any_instance.stubs(:get_layout).returns('application')

    parent = Category.create!(:name => "Parent Category", :environment => Environment.default, :display_color => '#888a85')
    @category = Category.create!(:name => "Category A", :environment => Environment.default, :parent => parent)
  end

  should 'link to uncategorized assets at site root' do
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/search/contents' }
  end

  should 'link to assets inside category root' do
    (1..SearchController::MULTIPLE_SEARCH_LIMIT+1).each do |i|
      enterprise = Enterprise.create! :identifier => "ent#{i}", :name => "enterprise#{i}"
      ProfileCategorization.add_category_to_profile(@category, enterprise)
    end

    get '/cat/parent-category/category-a'
    assert_tag :tag => 'a', :attributes => { :href => '/search/enterprises/parent-category/category-a' }
  end

end
