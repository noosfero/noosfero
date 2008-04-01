require "#{File.dirname(__FILE__)}/../test_helper"

class SearchPopupTest < ActionController::IntegrationTest

  should 'link to search without category when not inside a filter' do
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/search/popup' }
  end

  should 'link to search with category when inside a filter' do
    parent = Category.create!(:name => 'cat1', :environment => Environment.default)
    Category.create!(:name => 'subcat', :environment => Environment.default, :parent => parent)

    get '/cat/cat1/subcat'
    assert_tag :tag => 'a', :attributes => { :href => '/search/popup/cat1/subcat' }
  end

end
