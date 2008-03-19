require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'filter stop words' do
    @controller.expects(:locale).returns('pt_BR').at_least_once
    get 'index', :query => 'a carne da vaca'
    assert_response :success
    assert_template 'index'
    assert_equal 'carne vaca', assigns('filtered_query')
  end

  should 'search only in specified types of content' do
    get :index, :query => 'something not important', :find_in => [ 'articles' ]
    assert_equal [:articles], assigns(:results).keys
  end

  should 'search in more than one specified types of content' do
    get :index, :query => 'something not important', :find_in => [ 'articles', 'comments' ]
    assert_equivalent [:articles, :comments ], assigns(:results).keys
  end

  should 'render success in search' do
    get :index, :query => 'something not important'
    assert_response :success
  end

  should 'search for articles' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!

    get 'index', :query => 'article found', :find_in => [ 'articles' ]

    assert_includes assigns(:results)[:articles], art
  end

  should 'search for articles in a specific category' do
    person = create_user('teste').person
    category = Category.create!(:name => 'my category', :environment => Environment.default)

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << category
    art1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!

    get :filter, :category_path => [ 'my-category' ], :query => 'article found', :find_in => [ 'articles' ]

    assert_includes assigns(:results)[:articles], art1
    assert_not_includes assigns(:results)[:articles], art2
  end

  should 'search in comments' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment.save!
    get 'index', :query => 'found', :find_in => [ 'comments' ]

    assert_includes assigns(:results)[:comments], comment
  end

  should 'search in comments in a specific category'


  should 'find in environment' do
    env = mock
    finder = SearchController::Finder.new(env)
    assert_same env, finder.environment
  end

  should 'delegate to environment in default finder' do
    env = mock
    articles = mock
    finder = SearchController::Finder.new(env)
    env.expects(:articles).returns(articles)
    assert_same articles, finder.articles
  end

  should 'find people'
  should 'find communities'

  should 'find enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    get 'index', :query => 'teste'
    assert_includes assigns(:results)[:enterprises], ent
  end

  should 'find products'

end
