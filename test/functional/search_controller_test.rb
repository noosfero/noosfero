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

  def test_local_files_reference
    assert_local_files_reference
  end

  def test_valid_xhtml
    assert_valid_xhtml
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
    get 'index', :query => 'a carne da vaca'

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

    assert_equal [p2,p1], assigns(:results)[:people].instance_variable_get('@results')
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
    assert_equal [c2, c1], assigns(:results)[:communities].instance_variable_get('@results')
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
    assert_equivalent [prod2, prod1], assigns(:results)[:products]
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
      assert_tag :tag => 'div', :attributes => { :class => /search-results-#{thing}/ }, :descendant => { :tag => 'h3', :content => description }
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
      assert_tag :tag => 'label', :content => description
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
    recent = []
    finger = CategoryFinder.new(@category)
    finger.expects(:recent).with(anything).at_least_once
    finger.expects(:recent).with('articles').returns(recent)
    CategoryFinder.expects(:new).with(@category).returns(finger)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:results)[:recent_articles]
  end

  should 'list recent comments in the category' do
    recent = []
    finger = CategoryFinder.new(@category)
    finger.expects(:recent).with(anything).at_least_once
    finger.expects(:recent).with('comments').returns(recent)
    CategoryFinder.expects(:new).with(@category).returns(finger)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:results)[:recent_comments]
  end

  should 'list most commented articles in the category' do
    most_commented = []
    finger = CategoryFinder.new(@category)
    finger.expects(:most_commented_articles).returns(most_commented)
    CategoryFinder.expects(:new).with(@category).returns(finger)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same most_commented, assigns(:results)[:most_commented_articles]
  end

  should 'list recently registered people in the category' do
    recent_people = []
    finger = CategoryFinder.new(@category)
    finger.expects(:recent).with(anything).at_least_once
    finger.expects(:recent).with('people').returns(recent_people)
    CategoryFinder.expects(:new).with(@category).returns(finger)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent_people, assigns(:results)[:recent_people]
  end

  should 'list recently registered communities in the category' do
    recent_communities = []
    finger = CategoryFinder.new(@category)
    finger.expects(:recent).with(anything).at_least_once
    finger.expects(:recent).with('communities').returns(recent_communities)
    CategoryFinder.expects(:new).with(@category).returns(finger)

    get :category_index, :category_path => [ 'my-category' ]
    assert_same recent_communities, assigns(:results)[:recent_communities]
  end

  should 'not list "Search for ..." in category_index' do
    get :category_index, :category_path => [ 'my-category' ]
    assert_no_tag :content => /Search for ".*" in the whole site/
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

  should 'not use design blocks' do
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes' }
  end

  should 'offer text box to enter a new search in general context' do
    get :index, :query => 'a sample search'
    assert_tag :tag => 'form', :attributes => { :action => '/search' }, :descendant => {
      :tag => 'input',
      :attributes => { :name => 'query', :value => 'a sample search' }
    }
  end

  should 'offer text box to enter a new seach in specific context' do
    get :index, :category_path => [ 'my-category'], :query => 'a sample search'
    assert_tag :tag => 'form', :attributes => { :action => '/search/index/my-category' }, :descendant => {
      :tag => 'input',
      :attributes => { :name => 'query', :value => 'a sample search' }
    }
  end

  should 'offer link to do the same search as before in general context' do
    get :index, :category_path => [ 'my-category' ], :query => 'a sample search'
    assert_tag :tag => 'a', :attributes => { :href => "/search?query=a+sample+search" }, :content => 'Search for "a sample search" in the whole site'
  end

  should 'display only category name in "search results for ..." title' do
    parent = Category.create!(:name => 'Parent Category', :environment => Environment.default)
    child = Category.create!(:name => "Child Category", :environment => Environment.default, :parent => parent)

    get :index, :category_path => [ 'parent-category', 'child-category' ], :query => 'a sample search'
    assert_tag :tag => 'h1', :content => /Search results for &quot;a sample search&quot; in &quot;Child Category&quot;/
  end

  should 'search in categoty hierachy' do
    parent = Category.create!(:name => 'Parent Category', :environment => Environment.default)
    child  = Category.create!(:name => 'Child Category', :environment => Environment.default, :parent => parent)

    p = create_user('test_profile').person
    p.categories << child
    p.save!

    Profile.rebuild_index

    get :index, :category_path => ['parent-category'], :query => 'test_profile', :find_in => ['people']

    assert_includes assigns(:results)[:people], p
  end

  should 'keep asset selection for new searches' do
    get :index, :query => 'a sample query', :find_in => [ 'people', 'communities' ]
    assert_tag :tag => 'input', :attributes =>  { :name => 'find_in[]', :value => 'people', :checked => 'checked' }
    assert_tag :tag => 'input', :attributes =>  { :name => 'find_in[]', :value => 'communities', :checked => 'checked' }
    assert_no_tag :tag => 'input', :attributes =>  { :name => 'find_in[]', :value => 'enterprises', :checked => 'checked' }
    assert_no_tag :tag => 'input', :attributes =>  { :name => 'find_in[]', :value => 'products', :checked => 'checked' }
  end

  ############## directory ####################
  should 'link to people directory in index' do
    get :assets, :asset => 'people'
    assert_tag :tag => 'a', :attributes => { :href => '/directory/people/a'}, :content => 'A'
    assert_tag :tag => 'a', :attributes => { :href => '/directory/people/b'}, :content => 'B'
  end

  should 'display link in people directory to other initials but not to the same' do
    get :directory, :asset => 'people', :initial => 'r'
    assert_tag :tag => 'a', :attributes => { :href => '/directory/people/a' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/directory/people/r' }
  end

  should 'display link to recent people while in directory' do
    get :directory, :asset => 'people', :initial => 'a'
    assert_tag :tag => 'a', :attributes => { :href => '/assets/people' }, :content => 'Recent'
  end

  ############### directory for every kind of asset #################
  should 'display people with a given initial' do
    included = create_user('fergunson').person
    not_included = create_user('yanerson').person

    get :directory, :asset => 'people', :initial => 'f'
    assert_includes assigns(:results)[:people], included
    assert_not_includes assigns(:results)[:people], not_included
  end

  should 'display communities with a given initial' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'beautiful community (another)', :identifier => 'an_bea_comm', :environment => Environment.default)

    get :directory, :asset => 'communities', :initial => 'a'

    assert_includes assigns(:results)[:communities], c1
    assert_not_includes assigns(:results)[:communities], c2
  end

  should 'display enterprises with a given initial' do
    ent1 = Enterprise.create!(:name => 'aaaaa', :identifier => 'teste1')
    ent2 = Enterprise.create!(:name => 'bbbbb', :identifier => 'teste2')

    get :directory, :asset => 'enterprises', :initial => 'a'

    assert_includes assigns(:results)[:enterprises], ent1
    assert_not_includes assigns(:results)[:enterprises], ent2
  end

  should 'display products with a given initial' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    prod1 = ent.products.create!(:name => 'a beautiful product')
    prod2 = ent.products.create!(:name => 'beautiful product (another)')

    get :directory, :asset => 'products', :initial => 'a'

    assert_includes assigns(:results)[:products], prod1
    assert_not_includes assigns(:results)[:products], prod2
  end

  should 'display articles with a given initial' do
    person = create_user('teste').person
    art1 = person.articles.build(:name => 'an article to be found'); art1.save!
    art2 = person.articles.build(:name => 'better article'); art2.save!

    get :directory, :asset => 'articles', :initial => 'a'

    assert_includes assigns(:results)[:articles], art1
    assert_not_includes assigns(:results)[:articles], art2
  end

  should 'display comments with a given initial' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!

    comment1 = art.comments.build(:title => 'a comment to be found', :body => 'hfyfyh', :author => person); comment1.save!
    comment2 = art.comments.build(:title => 'better comment, but not found', :body => 'hfyfyh', :author => person); comment2.save!

    get :directory, :asset => 'comments', :initial => 'a'

    assert_includes assigns(:results)[:comments], comment1
    assert_not_includes assigns(:results)[:comments], comment2
  end


  should 'display people with a given initial, under a specific category' do

    in_category_and_with_initial = create_user('fergunson').person
    in_category_and_with_initial.categories << @category

    in_category_but_without_initial = create_user('yanerson').person
    in_category_but_without_initial.categories << @category

    not_in_category_but_with_initial = create_user('fergy').person
    not_in_category_and_without_initial = create_user('xalanxalan').person

    get :directory, :asset => 'people', :initial => 'f', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:people], in_category_and_with_initial
    assert_not_includes assigns(:results)[:people], in_category_but_without_initial
    assert_not_includes assigns(:results)[:people], not_in_category_but_with_initial
    assert_not_includes assigns(:results)[:people], not_in_category_and_without_initial
  end

  should 'display communities with a given initial, under a specific category' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default); c1.categories << @category
    c2 = Community.create!(:name => 'beautiful community (another)', :identifier => 'an_bea_comm', :environment => Environment.default); c2.categories << @category

    c3 = Community.create!(:name => 'another beautiful community', :identifier => 'lalala', :environment => Environment.default);
    c4 = Community.create!(:name => 'damn beautiful community (another)', :identifier => 'lelele', :environment => Environment.default)

    get :directory, :asset => 'communities', :initial => 'a', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:communities], c1
    assert_not_includes assigns(:results)[:communities], c2
    assert_not_includes assigns(:results)[:communities], c3
    assert_not_includes assigns(:results)[:communities], c4
  end

  should 'display enterprises with a given initial, under a specific category' do
    ent1 = Enterprise.create!(:name => 'aaaaa', :identifier => 'teste1'); ent1.categories << @category
    ent2 = Enterprise.create!(:name => 'bbbbb', :identifier => 'teste2'); ent1.categories << @category
    ent3 = Enterprise.create!(:name => 'aaaa1111', :identifier => 'teste1111')
    ent4 = Enterprise.create!(:name => 'ddddd', :identifier => 'teste2222')

    get :directory, :asset => 'enterprises', :initial => 'a', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:enterprises], ent1
    assert_not_includes assigns(:results)[:enterprises], ent2
    assert_not_includes assigns(:results)[:enterprises], ent3
    assert_not_includes assigns(:results)[:enterprises], ent4
  end

  should 'display products with a given initial, under a specific category' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    ent.categories << @category
    prod1 = ent.products.create!(:name => 'a beautiful product')
    prod2 = ent.products.create!(:name => 'beautiful product (another)')

    ent2 = Enterprise.create!(:name => 'test2', :identifier => 'test2')
    prod3 = ent2.products.create!(:name => 'another product')
    prod4 = ent2.products.create!(:name => 'damn product (another)')

    get :directory, :asset => 'products', :initial => 'a', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:products], prod1
    assert_not_includes assigns(:results)[:products], prod2
    assert_not_includes assigns(:results)[:products], prod3
    assert_not_includes assigns(:results)[:products], prod4
  end

  should 'display articles with a given initial, under a specific category' do
    person = create_user('teste').person
    art1 = person.articles.build(:name => 'an article to be found'); art1.save!
    art1.categories << @category
    art2 = person.articles.build(:name => 'better article'); art2.save!
    art2.categories << @category

    art3 = person.articles.build(:name => 'another article to be found'); art3.save!
    art4 = person.articles.build(:name => 'damn article'); art4.save!


    get :directory, :asset => 'articles', :initial => 'a', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:articles], art1
    assert_not_includes assigns(:results)[:articles], art2
    assert_not_includes assigns(:results)[:articles], art3
    assert_not_includes assigns(:results)[:articles], art4
  end

  should 'display comments with a given initial, under a specific category' do
    person = create_user('teste').person
    art = person.articles.build(:name => 'an article to be found'); art.save!
    art.categories << @category
    comment1 = art.comments.build(:title => 'a comment to be found', :body => 'hfyfyh', :author => person); comment1.save!
    comment2 = art.comments.build(:title => 'better comment, but not found', :body => 'hfyfyh', :author => person); comment2.save!

    art2 = person.articles.build(:name => 'another article to be found'); art2.save!
    comment3 = art2.comments.build(:title => 'a comment to be found', :body => 'hfyfyh', :author => person); comment1.save!
    comment4 = art2.comments.build(:title => 'better comment, but not found', :body => 'hfyfyh', :author => person); comment2.save!


    get :directory, :asset => 'comments', :initial => 'a', :category_path => [ 'my-category' ]

    assert_includes assigns(:results)[:comments], comment1
    assert_not_includes assigns(:results)[:comments], comment2
    assert_not_includes assigns(:results)[:comments], comment3
    assert_not_includes assigns(:results)[:comments], comment4
  end

end
