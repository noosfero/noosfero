require File.dirname(__FILE__) + '/../test_helper'
require 'profile_search_controller'

# Re-raise errors caught by the controller.
class ProfileSearchController; def rescue_action(e) raise e end; end

class ProfileSearchControllerTest < Test::Unit::TestCase
  def setup
    Test::Unit::TestCase::setup
    @controller = ProfileSearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @person = fast_create(Person)
  end
  attr_reader :person

  should 'espape xss attack' do
    @controller.expects(:profile).returns(person).at_least_once
    get 'index', :profile => person.identifier, :q => '<wslite>'
    assert_no_tag :tag => 'wslite'
  end

  should 'render success in search' do
    get :index, :profile => person.identifier, :q => 'something not important'
    assert_response :success
  end

  should 'search for articles' do
    article = TextileArticle.create(:name => 'My article', :body => 'Article to test profile search', :profile => person)

    get 'index', :profile => person.identifier, :q => 'article profile'
    assert_includes assigns(:results), article
  end

  should 'display search results' do
    article1 = fast_create(Article, {:body => '<p>Article to test profile search</p>', :profile_id => person.id}, :search => true)
    article2 = fast_create(Article, {:body => '<p>Another article to test profile search</p>', :profile_id => person.id}, :search => true)

    get 'index', :profile => person.identifier, :q => 'article'

    [article1, article2].each do |article|
      assert_tag :tag => 'li', :descendant => { :tag => 'a', :content => article.short_lead, :attributes => { :class => /article-details/ }}
    end
  end

  should 'paginate results listing' do
    (1..11).each do |i|
      TextileArticle.create!(:name => "Article #{i}", :profile => person, :language => 'en')
    end

    get 'index', :profile => person.identifier, :q => 'Article'

    assert_equal 10, assigns(:results).size
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{person.identifier}/search?page=2&amp;q=Article", :rel => 'next' }
  end

  should 'display abstract if given' do
    article1 = TextileArticle.create(:name => 'Article 1', :abstract => 'Abstract to test', :body => 'Article to test profile search', :profile => person)
    article2 = TextileArticle.create(:name => 'Article 2', :body => 'Another article to test profile search', :profile => person)

    get 'index', :profile => person.identifier, :q => 'article profile'

    assert_tag :tag => 'li', :descendant => { :tag => 'a', :content => article1.abstract, :attributes => { :class => /article-details/ }}
    assert_no_tag :tag => 'li', :descendant => { :tag => 'a', :content => article1.body, :attributes => { :class => /article-details/ }}

    assert_tag :tag => 'li', :descendant => { :tag => 'a', :content => article2.body, :attributes => { :class => /article-details/ }}
  end

  should 'display nothing if search is blank' do
    article1 = TextileArticle.create(:name => 'Article 1', :body => 'Article to test profile search', :profile => person)
    article2 = TextileArticle.create(:name => 'Article 2', :body => 'Another article to test profile search', :profile => person)

    get 'index', :profile => person.identifier, :q => ''

    assert_no_tag :tag => 'ul', :attributes => { :id => 'profile-search-results'}, :descendant => { :tag => 'li' }
  end

  should 'not display private articles' do
    article1 = TextileArticle.create(:name => 'Article 1', :body => 'Article to test profile search', :profile => person, :published => false)
    article2 = TextileArticle.create(:name => 'Article 2', :body => 'Another article to test profile search', :profile => person)

    get 'index', :profile => person.identifier, :q => 'article profile'

    assert_no_tag :tag => 'li', :descendant => { :tag => 'a', :content => article1.body, :attributes => { :class => /article-details/ }}

    assert_tag :tag => 'li', :descendant => { :tag => 'a', :content => article2.body, :attributes => { :class => /article-details/ }}
  end

  should 'display number of results found' do
    article1 = TextileArticle.create(:name => 'Article 1', :body => 'Article to test profile search', :body => 'Article to test profile search', :profile => person)
    article2 = TextileArticle.create(:name => 'Article 2', :body => 'Another article to test profile search', :profile => person)

    get 'index', :profile => person.identifier, :q => 'article profile'

    assert_tag :tag => 'div', :attributes => { :class => 'results-found-message' }, :content => /2 results found/
  end

end
