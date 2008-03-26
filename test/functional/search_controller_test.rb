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

  should 'search with filtered query' do
    @controller.expects(:locale).returns('pt_BR').at_least_once
    @controller.expects(:search).with(anything, 'carne vaca').at_least_once
    @controller.expects(:search).with(anything, 'a carne da vaca').never
    get 'index', :query => 'a carne da vaca'
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
  
  # 'assets' menu
  should 'list articles in a specific category'

  should 'search in comments' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment.save!
    get 'index', :query => 'found', :find_in => [ 'comments' ]

    assert_includes assigns(:results)[:comments], comment
  end

  should 'search in comments in a specific category' do
    person = create_user('teste').person
    category = Category.create!(:name => 'my category', :environment => Environment.default)

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << category
    art1.save!
    comment1 = art1.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save! 
    comment2 = art2.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment2.save!
    get 'filter', :category_path => ['my-category'], :query => 'found', :find_in => [ 'comments' ]

    assert_includes assigns(:results)[:comments], comment1
    assert_not_includes assigns(:results)[:comments], comment2
  end

  should 'find enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    get 'index', :query => 'teste', :find_in => [ 'enterprises' ]
    assert_includes assigns(:results)[:enterprises], ent
  end
  
  should 'find enterprises in a specified category' do
    category = Category.create!(:name => 'my category', :environment => Environment.default)

    # in category
    ent1 = Enterprise.create!(:name => 'testing enterprise 1', :identifier => 'test1', :categories => [category])

    # not in category
    ent2 = Enterprise.create!(:name => 'testing enterprise 2', :identifier => 'test2')

    get :filter, :category_path => [ 'my-category' ], :query => 'testing', :find_in => [ 'enterprises' ]

    assert_includes assigns(:results)[:enterprises], ent1
    assert_not_includes assigns(:results)[:enterprises], ent2
  end

  # 'assets' menu
  should 'list enterprises in a specified category'

  should 'find people' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.save!
    get :index, :query => 'beautiful', :find_in => [ 'people' ]
    assert_includes assigns(:results)[:people], p1
  end

  should 'find people in a specific category' do
    c = Category.create!(:name => 'my category', :environment => Environment.default)
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.categories << c; p1.save!
    p2 = create_user('people_2').person; p2.name = 'another beautiful person'; p2.save!
    get :filter, :category_path => [ 'my-category' ], :query => 'beautiful', :find_in => [ 'people' ]
    assert_includes assigns(:results)[:people], p1
    assert_not_includes assigns(:results)[:people], p2
  end

  # 'assets' menu
  should 'list people in a specified category'

  should 'find communities' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    get :index, :query => 'beautiful', :find_in => [ 'communities' ]
    assert_includes assigns(:results)[:communities], c1
  end

  should 'find communities in a specified category' do
    c = Category.create!(:name => 'my category', :environment => Environment.default)
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)
    c1.categories << c; c1.save!
    get :filter, :category_path => [ 'my-category' ], :query => 'beautiful', :find_in => [ 'communities' ]
    assert_includes assigns(:results)[:communities], c1
    assert_not_includes assigns(:results)[:communities], c2
  end
  # 'assets' menu
  should 'list communities in a specified category'

  should 'find products' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod = ent.products.create!(:name => 'a beautiful product')
    get 'index', :query => 'beautiful', :find_in => ['products']
    assert_includes assigns(:results)[:products], prod
  end

  should 'find products in a specific category' do
    c = Category.create!(:name => 'my category', :environment => Environment.default)
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1'); ent1.categories << c
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product')
    prod2 = ent2.products.create!(:name => 'another beautiful product')
    get 'filter', :category_path => ['my-category'], :query => 'beautiful', :find_in => ['products']
    assert_includes assigns(:results)[:products], prod1
    assert_not_includes assigns(:results)[:products], prod2
  end

  # 'assets' menu
  should 'list products in a specific category'

end
