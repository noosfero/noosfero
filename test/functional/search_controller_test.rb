require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @category = Category.create!(:name => 'my category', :environment => Environment.default)
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

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << @category
    art1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!

    get :index, :category_path => [ 'my-category' ], :query => 'article found', :find_in => [ 'articles' ]

    assert_includes assigns(:results)[:articles], art1
    assert_not_includes assigns(:results)[:articles], art2
  end
  
  # 'assets' outside any category
  should 'list articles in general' do
    person = create_user('testuser').person
    person2 = create_user('anotheruser').person

    art1 = person.articles.create!(:name => 'one article', :categories => [@category])

    art2 = person2.articles.create!(:name => 'two article', :categories => [@category])

    get :assets, :asset => 'articles'

    assert_includes assigns(:results)[:articles], art1
    assert_includes assigns(:results)[:articles], art2
  end
  
  # 'assets' inside a category
  should 'list articles in a specific category' do
    person = create_user('testuser').person

    # in category
    art1 = person.articles.create!(:name => 'one article', :categories => [@category])
    art2 = person.articles.create!(:name => 'other article', :categories => [@category])

    # not in category
    art3 = person.articles.create!(:name => 'another article')

    get :assets, :asset => 'articles', :category_path => ['my-category']

    assert_includes assigns(:results)[:articles], art1
    assert_includes assigns(:results)[:articles], art2
    assert_not_includes assigns(:results)[:articles], art3
  end

  should 'search in comments' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment.save!
    get 'index', :query => 'found', :find_in => [ 'comments' ]

    assert_includes assigns(:results)[:comments], comment
  end

  should 'search in comments in a specific category' do
    person = create_user('teste').person

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << @category
    art1.save!
    comment1 = art1.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save! 
    comment2 = art2.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment2.save!
    get :index, :category_path => ['my-category'], :query => 'found', :find_in => [ 'comments' ]

    assert_includes assigns(:results)[:comments], comment1
    assert_not_includes assigns(:results)[:comments], comment2
  end

  # 'assets' menu outside any category
  should 'list comments in general' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    comment = art.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment.save!

    get :assets, :asset => 'comments'
    assert_includes assigns(:results)[:comments], comment
  end

  # 'assets' menu inside a specific category
  should 'list comments in a specified category' do
    person = create_user('teste').person

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << @category
    art1.save!
    comment1 = art1.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!
    comment2 = art2.comments.build(:title => 'comment to be found', :body => 'hfyfyh', :author => person); comment2.save!


    get :assets, :asset => 'comments', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:comments], comment1
    assert_not_includes assigns(:results)[:comments], comment2
  end

  should 'find enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    get 'index', :query => 'teste', :find_in => [ 'enterprises' ]
    assert_includes assigns(:results)[:enterprises], ent
  end
  
  should 'find enterprises in a specified category' do

    # in category
    ent1 = Enterprise.create!(:name => 'testing enterprise 1', :identifier => 'test1', :categories => [@category])

    # not in category
    ent2 = Enterprise.create!(:name => 'testing enterprise 2', :identifier => 'test2')

    get :index, :category_path => [ 'my-category' ], :query => 'testing', :find_in => [ 'enterprises' ]

    assert_includes assigns(:results)[:enterprises], ent1
    assert_not_includes assigns(:results)[:enterprises], ent2
  end

  should 'list enterprises in general' do
    ent1 = Enterprise.create!(:name => 'teste 1', :identifier => 'teste1')
    ent2 = Enterprise.create!(:name => 'teste 2', :identifier => 'teste2')

    get :assets, :asset => 'enterprises'
    assert_includes assigns(:results)[:enterprises], ent1
    assert_includes assigns(:results)[:enterprises], ent2
  end

  # 'assets' menu inside a category
  should 'list enterprises in a specified category' do
    # in category
    ent1 = Enterprise.create!(:name => 'teste 1', :identifier => 'teste1', :categories => [@category])

    # not in category
    ent2 = Enterprise.create!(:name => 'teste 2', :identifier => 'teste2')

    get :assets, :asset => 'enterprises', :category_path => [ 'my-category' ]
    assert_includes assigns(:results)[:enterprises], ent1
    assert_not_includes assigns(:results)[:enterprises], ent2
  end

  should 'find people' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.save!
    get :index, :query => 'beautiful', :find_in => [ 'people' ]
    assert_includes assigns(:results)[:people], p1
  end

  should 'find people in a specific category' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.categories << @category; p1.save!
    p2 = create_user('people_2').person; p2.name = 'another beautiful person'; p2.save!
    get :index, :category_path => [ 'my-category' ], :query => 'beautiful', :find_in => [ 'people' ]
    assert_includes assigns(:results)[:people], p1
    assert_not_includes assigns(:results)[:people], p2
  end

  # 'assets' menu outside any category
  should 'list people in general' do
    Profile.delete_all

    p1 = create_user('test1').person
    p2 = create_user('test2').person

    get :assets, :asset => 'people'
    assert_equal [p2,p1], assigns(:results)[:people]
  end

  # 'assets' menu inside a category
  should 'list people in a specified category' do
    Profile.delete_all

    # in category
    p1 = create_user('test1').person; p1.categories << @category

    # not in category
    p2 = create_user('test2').person

    get :assets, :asset => 'people', :category_path => [ 'my-category' ]
    assert_equal [p1], assigns(:results)[:people]
  end

  should 'find communities' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    get :index, :query => 'beautiful', :find_in => [ 'communities' ]
    assert_includes assigns(:results)[:communities], c1
  end

  should 'find communities in a specified category' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)
    c1.categories << @category; c1.save!
    get :index, :category_path => [ 'my-category' ], :query => 'beautiful', :find_in => [ 'communities' ]
    assert_includes assigns(:results)[:communities], c1
    assert_not_includes assigns(:results)[:communities], c2
  end

  # 'assets' menu outside any category
  should 'list communities in general' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)

    get :assets, :asset => 'communities'
    assert_equal [c2, c1], assigns(:results)[:communities]
  end

  # 'assets' menu
  should 'list communities in a specified category' do

    # in category
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c1.categories << @category

    # not in category
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)

    # in category
    c3 = Community.create!(:name => 'yet another beautiful community', :identifier => 'yet_an_bea_comm', :environment => Environment.default)
    c3.categories << @category

    get :assets, :asset => 'communities', :category_path => [ 'my-category' ]
    assert_equal [c3, c1], assigns(:results)[:communities]
  end

  should 'find products' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod = ent.products.create!(:name => 'a beautiful product')
    get 'index', :query => 'beautiful', :find_in => ['products']
    assert_includes assigns(:results)[:products], prod
  end

  should 'find products in a specific category' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1'); ent1.categories << @category
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product')
    prod2 = ent2.products.create!(:name => 'another beautiful product')
    get :index, :category_path => ['my-category'], :query => 'beautiful', :find_in => ['products']
    assert_includes assigns(:results)[:products], prod1
    assert_not_includes assigns(:results)[:products], prod2
  end

  # 'assets' menu outside any category
  should 'list products in general' do
    Profile.delete_all

    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product')
    prod2 = ent2.products.create!(:name => 'another beautiful product')

    get :assets, :asset => 'products'
    assert_equal [prod2, prod1], assigns(:results)[:products]
  end

  # 'assets' menu inside a category
  should 'list products in a specific category' do
    Profile.delete_all

    # in category
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1'); ent1.categories << @category
    prod1 = ent1.products.create!(:name => 'a beautiful product')

    # not in category
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod2 = ent2.products.create!(:name => 'another beautiful product')

    get :assets, :asset => 'products', :category_path => [ 'my-category' ]

    assert_equal [prod1], assigns(:results)[:products]
  end

  should 'display search results' do
    ent = Enterprise.create!(:name => 'display enterprise', :identifier => 'teste1')
    product = ent.products.create!(:name => 'display product')
    person = create_user('displayperson').person; person.name = 'display person'; person.save!
    article = person.articles.create!(:name => 'display article')
    comment = article.comments.create!(:title => 'display comment', :body => '...', :author => person)
    community = Community.create!(:name => 'display community', :identifier => 'an_bea_comm')
    
    get :index, :query => 'display'
    
    names = {
        :articles => 'Articles',
        :comments => 'Comments',
        :people => 'People',
        :enterprises => 'Enterprises',
        :communities => 'Communities',
        :products => 'Products',
    }
    names.each do |thing, description|
      assert_tag :tag => 'div', :attributes => { :id => "search-results-#{thing}" }, :descendant => { :tag => 'h3', :content => description }
      assert_tag :tag => 'a', :content => "display #{thing.to_s.singularize}"
    end
  end

  should 'present options of where to search' do
    get :popup
    names = {
        :articles => 'Articles',
        :comments => 'Comments',
        :people => 'People',
        :enterprises => 'Enterprises',
        :communities => 'Communities',
        :products => 'Products',
    }
    names.each do |thing,description|
      assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => "find_in[]", :value => thing.to_s, :checked => 'checked' }
      assert_tag :tag => 'span', :content => description
    end
  end

  should 'not display option to choose where to search when not inside filter' do
    get :popup
    assert_no_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'search_whole_site', :value => 'yes' }
  end

  should 'display option to choose searching in whole site or in current category' do
    parent = Category.create!(:name => 'cat', :environment => Environment.default)
    Category.create!(:name => 'sub', :environment => Environment.default, :parent => parent)

    get :popup, :category_path => [ 'cat', 'sub']
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'search_whole_site', :value => 'yes' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'search_whole_site', :value => 'no', :checked => 'checked' }
  end

  should 'search in whole site when told so' do
    parent = Category.create!(:name => 'randomcat', :environment => Environment.default)
    Category.create!(:name => 'randomchild', :environment => Environment.default, :parent => parent)

    get :index, :category_path => [ 'randomcat', 'randomchild' ], :query => 'some random query', :search_whole_site => 'yes'

    # search_whole_site must be removed to precent a infinite redirect loop
    assert_redirected_to :action => 'index', :category_path => [], :query => 'some random query', :search_whole_site => nil
  end

  should 'submit form to root when not inside a filter' do
    get :popup
    assert_tag :tag => 'form', :attributes => { :action => '/search' }
  end

  should 'submit form to category path when inside a filter' do
    get :popup, :category_path => Category.create!(:name => 'mycat', :environment => Environment.default).explode_path
    assert_tag :tag => 'form', :attributes => { :action => '/search/index/mycat' }
  end

  should 'use GET method to search' do
    get :popup
    assert_tag :tag => 'form' , :attributes => { :method => 'get' }
  end

  def test_should_display_a_given_category
    get :category_index, :category_path => [ 'my-category' ]
    assert_equal @category, assigns(:category)
  end

  should 'expose category in a method' do
    get :category_index, :category_path => [ 'my-category' ]
    assert_same assigns(:category), @controller.category
  end

  should 'list recent articles in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    recent = []
    @category.expects(:recent_articles).returns(recent)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:recent_articles)
  end

  should 'list recent comments in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    recent = []
    @category.expects(:recent_comments).returns(recent)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:recent_comments)
  end

  should 'list most commented articles in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    most_commented = []
    @category.expects(:most_commented_articles).returns(most_commented)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same most_commented, assigns(:most_commented_articles)
  end

  should 'display category of products' do
    cat = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    ent = Enterprise.create!(:name => 'Enterprise test', :identifier => 'enterprise_test')
    p = cat.products.create!(:name => 'product test', :enterprise => ent)
    get :category_index, :category_path => cat.path.split('/')
    assert_includes assigns(:products), p
  end

  # SECURITY
  should 'not allow unrecognized assets' do
    get :assets, :asset => 'unexisting_asset'
    assert_response 403
  end

  should 'expose asset name in instance variable' do
    get :assets, :asset => 'products'
    assert_equal 'Products', assigns(:asset_name)
  end
  
end
