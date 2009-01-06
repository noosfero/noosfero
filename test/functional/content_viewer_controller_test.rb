require File.dirname(__FILE__) + '/../test_helper'
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < Test::Unit::TestCase

  all_fixtures

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
  end
  attr_reader :profile

  def test_local_files_reference
    page = profile.articles.build(:name => 'test')
    page.save!
    assert_local_files_reference :get, :view_page, :profile => profile.identifier, :page => [ 'test' ]
  end

  def test_valid_xhtml
    assert_valid_xhtml
  end

  def test_should_display_page
    page = profile.articles.build(:name => 'test')
    page.save!

    uses_host 'colivre.net'
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response :success
    assert_equal page, assigns(:page)
  end

  def test_should_display_homepage
    a = profile.articles.build(:name => 'test')
    a.save!
    profile.home_page = a
    profile.save!

    get :view_page, :profile => profile.identifier, :page => [ 'test']

    assert_response :success
    assert_template 'view_page'
    assert_equal a, assigns(:page)
  end

  def test_should_display_something_else_for_empty_homepage
    profile.articles.destroy_all

    get :view_page, :profile => profile.identifier, :page => []

    assert_response :success
    assert_template 'no_home_page'
  end

  def test_should_get_not_found_error_for_unexisting_page
    uses_host 'anhetegua.net'
    get :view_page, :profile => 'aprofile', :page => ['some_unexisting_page']
    assert_response :missing
  end

  def test_should_get_not_found_error_for_unexisting_profile
    Profile.delete_all
    uses_host 'anhetegua'
    get :view_page, :profile => 'some_unexisting_profile', :page => []
    assert_response :missing
  end

  def test_should_be_able_to_post_comment_while_authenticated
    profile = create_user('popstar').person
    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
    page.save!
    profile.home_page = page; profile.save!

    assert_difference Comment, :count do
      login_as('ze')
      post :view_page, :profile => 'popstar', :page => [ 'myarticle' ], :comment => { :title => 'crap!', :body => 'I think that this article is crap' }
    end
  end

  def test_should_be_able_to_post_comment_while_not_authenticated
    profile = create_user('popstar').person
    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
    page.save!
    profile.home_page = page; profile.save!
    
    assert_difference Comment, :count do
      post :view_page, :profile => 'popstar', :page => [ 'myarticle' ], :comment => { :title => 'crap!', :body => 'I think that this article is crap', :name => 'Anonymous coward', :email => 'coward@anonymous.com' }
    end
  end

  should 'produce a download-like when article is not text/html' do

    # for example, RSS feeds
    profile = create_user('someone').person
    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
    page.save!

    feed = RssFeed.new(:name => 'testfeed')
    feed.profile = profile
    feed.save!

    get :view_page, :profile => 'someone', :page => [ 'testfeed' ]

    assert_response :success
    assert_match /^text\/xml/, @response.headers['type']

    assert_equal feed.data, @response.body
  end

  should 'display remove comment button' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment.save!

    login_as 'testuser'
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_tag :tag => 'a', :attributes => { :href => '/testuser/test?remove_comment=' + comment.id.to_s }
  end

  should 'not add unneeded params for remove comment button' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment.save!

    login_as 'testuser'
    get :view_page, :profile => 'testuser', :page => [ 'test' ], :random_param => 'bli' # <<<<<<<<<<<<<<<
    assert_tag :tag => 'a', :attributes => { :href => '/testuser/test?remove_comment=' + comment.id.to_s }
  end

  should 'be able to remove comment' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment.save!

    login_as 'testuser'
    assert_difference Comment, :count, -1 do
      post :view_page, :profile => profile.identifier, :page => [ 'test' ], :remove_comment => comment.id
      assert_redirected_to :profile => 'testuser', :action => 'view_page', :page => [ 'test' ]
    end
  end

  should "not be able to remove other people's comments if not moderator or admin" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = article.comments.build(:author => commenter, :title => 'a comment', :body => 'lalala')
    comment.save!

    login_as 'normaluser' # normaluser cannot remove other people's comments
    assert_no_difference Comment, :count do
      post :view_page, :profile => profile.identifier, :page => [ 'test' ], :remove_comment => comment.id
      assert_response :redirect
    end
  end

  should 'be able to remove comments on their articles' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = article.comments.build(:author => commenter, :title => 'a comment', :body => 'lalala')
    comment.save!

    login_as 'testuser' # testuser must be able to remove comments in his articles
    assert_difference Comment, :count, -1 do
      post :view_page, :profile => profile.identifier, :page => [ 'test' ], :remove_comment => comment.id
      assert_response :redirect
    end
  end

  should 'not be able to post comment while inverse captcha field filled' do
    profile = create_user('popstar').person
    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
    page.save!
    profile.home_page = page; profile.save!

    assert_no_difference Comment, :count do
      post :view_page, :profile => profile.identifier, :page => [ 'myarticle' ], @controller.icaptcha_field => 'filled', :comment => { :title => 'crap!', :body => 'I think that this article is crap', :name => 'Anonymous coward', :email => 'coward@anonymous.com' }
    end
  end

  should 'be able to remove comments if is moderator' do
    commenter = create_user('commenter_user').person
    community = Community.create!(:name => 'Community test', :identifier => 'community-test')
    article = community.articles.create!(:name => 'test')
    comment = article.comments.create!(:author => commenter, :title => 'a comment', :body => 'lalala')
    community.add_moderator(profile)
    login_as profile.identifier
    assert_difference Comment, :count, -1 do
      post :view_page, :profile => community.identifier, :page => [ 'test' ], :remove_comment => comment.id
      assert_response :redirect
    end
  end

  should 'render inverse captcha field' do
    profile = create_user('popstar').person
    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
    page.save!
    profile.home_page = page; profile.save!
    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]
    assert_tag :tag => 'input', :attributes => { :type => 'text', :name => @controller.icaptcha_field }
  end

  should 'show error messages when make a blank comment' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post :view_page, :profile => @profile.identifier, :page => [ 'myarticle' ], :comment => { :title => '', :body => '' }
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'show comment form opened on error' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post :view_page, :profile => @profile.identifier, :page => [ 'myarticle' ], :comment => { :title => '', :body => '' }
    assert_tag :tag => 'div', :attributes => { :class => 'post_comment_box opened' }
  end

  should 'filter html content from body' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post :view_page, :profile => @profile.identifier, :page => [ 'myarticle' ],
      :comment => { :title => 'html comment', :body => "this is a <strong id='html_test_comment'>html comment</strong>" }
    assert_no_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should 'filter html content from title' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post :view_page, :profile => @profile.identifier, :page => [ 'myarticle' ],
      :comment => { :title => "html <strong id='html_test_comment'>comment</strong>", :body => "this is a comment" }
    assert_no_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should "point to article's url in comment form" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    Article.any_instance.stubs(:url).returns('http://www.mysite.com/person/article')

    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]

    assert_tag :tag => 'form', :attributes => { :id => /^comment_form/, :action => 'http://www.mysite.com/person/article' }
  end

  should "display current article's tags" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'test article', :tag_list => 'tag1, tag2')

    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]
    assert_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => {
      :tag => 'a',
      :attributes => { :href => "/profile/#{profile.identifier}/tag/tag1" }
    }
    assert_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => {
      :tag => 'a',
      :attributes => { :href => "/profile/#{profile.identifier}/tag/tag2" }
    }

    assert_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => { :content => /This article's tags:/ }
  end

  should "not display current article's tags" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'test article')

    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-tags' }
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => { :content => /This article's tags:/ }
  end

  should 'not display forbidden articles' do
    profile.articles.create!(:name => 'test')
    profile.update_attributes!(:public_content => false)

    Article.any_instance.expects(:display_to?).with(anything).returns(false)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response 403
  end

  should 'display allowed articles' do
    profile.articles.create!(:name => 'test')
    profile.update_attributes!(:public_content => false)

    Article.any_instance.expects(:display_to?).with(anything).returns(true)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response 200
  end

  should 'give 404 status on unexisting article' do
    profile.articles.delete_all
    get :view_page, :profile => profile.identifier, :page => [ 'VERY-UNPROBABLE-PAGE' ]
    assert_response 404
  end

  should 'show unpublished articles as unexisting' do
    profile.articles.create!(:name => 'test', :published => false)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response 404
  end

  should 'show unpublished articles to the user himself' do
    profile.articles.create!(:name => 'test', :published => false)

    login_as(profile.identifier)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response :success
  end

  should 'show unpublished articles to members' do
    community = Community.create!(:name => 'testcomm')
    community.articles.create!(:name => 'test', :published => false)
    community.add_member(profile)

    login_as(profile.identifier)
    get :view_page, :profile => community.identifier, :page => [ 'test' ]
    assert_response :success
  end

  should 'show message for disabled enterprises' do
    login_as(@profile.identifier)
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)
    get :view_page, :profile => ent.identifier, :page => []
    assert_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'not show message for disabled enterprise to non-enterprises' do
    login_as(@profile.identifier)
    @profile.enabled = false; @profile.save!
    get :view_page, :profile => @profile.identifier, :page => []
    assert_no_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'not show message for disabled enterprise if there is a block for it' do
    login_as(@profile.identifier)
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)
    ent.boxes << Box.new
    ent.boxes[0].blocks << DisabledEnterpriseMessageBlock.new
    ent.save
    get :view_page, :profile => ent.identifier, :page => []
    assert_no_tag :tag => 'div', :attributes => {:id => 'article'}, :descendant => { :tag => 'div', :attributes => { :id => 'profile-disabled' }}
  end

  should 'load the correct profile when using hosted domain' do
    profile = create_user('mytestuser').person
    profile.domains << Domain.create!(:name => 'micojones.net')
    profile.save!

    ActionController::TestRequest.any_instance.expects(:host).returns('www.micojones.net').at_least_once

    get :view_page, :page => []

    assert_equal profile, assigns(:profile)
  end

  should 'give link to edit the article for owner ' do
    login_as('testinguser')
    get :view_page, :profile => 'testinguser', :page => []
    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end
  should 'not give link to edit the article for non-logged-in people' do
    get :view_page, :profile => 'testinguser', :page => []
    assert_no_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end
  should 'not give link to edit article for other people' do
    login_as(create_user('anotheruser').login)

    get :view_page, :profile => 'testinguser', :page => []
    assert_no_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end

  should 'give link to create new article' do
    login_as('testinguser')
    get :view_page, :profile => 'testinguser', :page => []
    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end
  should 'give no link to create new article for non-logged in people ' do
    get :view_page, :profile => 'testinguser', :page => []
    assert_no_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end
  should 'give no link to create new article for other people' do
    login_as(create_user('anotheruser').login)
    get :view_page, :profile => 'testinguser', :page => []
    assert_no_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end

  should 'give link to create new article inside folder' do
    login_as('testinguser')
    folder = Folder.create!(:name => 'myfolder', :profile => @profile)
    get :view_page, :profile => 'testinguser', :page => [ 'myfolder' ]
    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should 'not give access to private articles if logged off' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :public_article => false)

    @request.stubs(:ssl?).returns(true)
    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'access_denied'
  end

  should 'not give access to private articles if logged in but not member' do
    login_as('testinguser')
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :public_article => false)

    @request.stubs(:ssl?).returns(true)
    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'access_denied'
  end

  should 'give access to private articles if logged in and member' do
    person = create_user('test_user').person
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :public_article => false)
    profile.affiliate(person, Profile::Roles.member)
    login_as('test_user')

    @request.stubs(:ssl?).returns(true)
    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'view_page'
  end

  should 'not be able to post comment if article do not accept it' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)

    assert_no_difference Comment, :count do
      post :view_page, :profile => profile.identifier, :page => [ 'myarticle' ], :comment => { :title => 'crap!', :body => 'I think that this article is crap', :name => 'Anonymous coward', :email => 'coward@anonymous.com' }
    end
  end

  should 'show link to publication on view' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    login_as(profile.identifier)

    get :view_page, :profile => profile.identifier, :page => ['myarticle']

    assert_tag :tag => 'a', :attributes => {:href => ('/myprofile/' + profile.identifier + '/cms/publish/' + page.id.to_s)}
  end

  should 'require SSL for viewing non-public articles' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'top secret', :public_article => false)
    get :view_page, :profile => 'testinguser', :page => [ 'myarticle' ]
    assert_redirected_to :protocol => 'https://', :profile => 'testinguser', :page => [ 'myarticle' ]
  end

  should 'not redirect to SSL if already on SSL' do
    @request.expects(:ssl?).returns(true).at_least_once
    page = profile.articles.create!(:name => 'myarticle', :body => 'top secret', :public_article => false)
    login_as('testinguser')
    get :view_page, :profile => 'testinguser', :page => [ 'myarticle' ]
    assert_response :success
  end
  
  should 'not show link to publication on view if not on person profile' do
    prof = Community.create!(:name => 'test comm', :identifier => 'test_comm')
    page = prof.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    prof.affiliate(profile, Profile::Roles.all_roles)
    login_as(profile.identifier)

    get :view_page, :profile => prof.identifier, :page => ['myarticle']

    assert_no_tag :tag => 'a', :attributes => {:href => ('/myprofile/' + prof.identifier + '/cms/publish/' + page.id.to_s)}
  end

  should 'deny access before trying SSL when SSL is disabled' do
    @controller.expects(:redirect_to_ssl).returns(false)
    profile = create_user('testuser').person
    profile.public_profile = false
    profile.save!

    get :view_page, :profile => 'testuser', :page => profile.home_page.explode_path
    assert_response 403
  end

  should 'redirect to new article path under an old path' do
    p = create_user('test_user').person
    a = p.articles.create(:name => 'old-name')
    old_path = a.explode_path
    a.name = 'new-name'
    a.save!

    get :view_page, :profile => p.identifier, :page => old_path

    assert_response :redirect
    assert_redirected_to :profile => p.identifier, :page => a.explode_path
  end

  should 'load new article name equal of another article old name' do
    p = create_user('test_user').person
    a1 = p.articles.create!(:name => 'old-name')
    old_path = a1.explode_path
    a1.name = 'new-name'
    a1.save!
    a2 = p.articles.create!(:name => 'old-name')

    get :view_page, :profile => p.identifier, :page => old_path

    assert_equal a2, assigns(:page)
  end

  should 'redirect to article with most recent version with the name if there is no article with the name' do
    p = create_user('test_user').person
    a1 = p.articles.create!(:name => 'old-name')
    old_path = a1.explode_path
    a1.name = 'new-name'
    a1.save!
    a2 = p.articles.create!(:name => 'old-name')
    a2.name = 'other-new-name'
    a2.save!

    get :view_page, :profile => p.identifier, :page => old_path

    assert_response :redirect
    assert_redirected_to :profile => p.identifier, :page => a2.explode_path
  end

  should 'not return an article of a different user' do
    p1 = create_user('test_user').person
    a = p1.articles.create!(:name => 'old-name')
    old_path = a.explode_path
    a.name = 'new-name'
    a.save!

    p2 = create_user('another_user').person

    get :view_page, :profile => p2.identifier, :page => old_path

    assert_response :missing
  end

  should 'not show a profile in an environment that is not its home environment' do
    p = Profile.create!(:identifier => 'mytestprofile', :name => 'My test profile', :environment => Environment.default)

    current = Environment.create!(:name => 'test environment')
    current.domains.create!(:name => 'example.com')
    uses_host 'www.example.com'

    get :view_page, :profile => 'mytestprofile', :page => []
    assert_response :missing
  end

  should 'display pagination links of blog' do
    blog = Blog.create!(:name => 'A blog test', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      blog.children << TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => blog)
    end
    assert_equal 10, blog.posts.size

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_tag :tag => 'a', :attributes => { :href => "/#{profile.identifier}/#{blog.path}?npage=2", :rel => 'next' }
  end

  should 'extract year and month from path' do
    blog = Blog.create!(:name => 'A blog test', :profile => profile)
    year, month = blog.created_at.year.to_s, '%02d' % blog.created_at.month
    get :view_page, :profile => profile.identifier, :page => [blog.path, year, month]
    assert_equal({ :year => year.to_s, :month => month.to_s }, assigns(:page).filter)
  end

  should 'give link to create new article inside folder when view child of folder' do
    login_as('testinguser')
    folder = Folder.create!(:name => 'myfolder', :profile => @profile)
    folder.children << TextileArticle.new(:name => 'children-article', :profile => @profile)
    get :view_page, :profile => 'testinguser', :page => [ 'myfolder', 'children-article' ]
    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should "display 'New article' when create children of folder" do
    login_as(profile.identifier)
    a = Folder.new(:name => 'article folder'); profile.articles << a;  a.save!
    Article.stubs(:short_description).returns('bli')
    get :view_page, :profile => profile.identifier, :page => [a.path]
    assert_tag :tag => 'a', :content => 'New article'
  end

  should "display 'New post' when create children of blog" do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    get :view_page, :profile => profile.identifier, :page => [a.path]
    assert_tag :tag => 'a', :content => 'New post'
  end

  should "display same label for new article button of parent" do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    t = TextileArticle.create!(:name => 'first post', :parent => a, :profile => profile)
    get :view_page, :profile => profile.identifier, :page => [t.path]
    assert_tag :tag => 'a', :content => 'New post'
  end

  should 'display button to remove article' do
    login_as(profile.identifier)
    t = TextileArticle.create!(:name => 'article to destroy', :profile => profile)
    get :view_page, :profile => profile.identifier, :page => [t.path]
    assert_tag :tag => 'a', :content => 'Delete', :attributes => {:href => "/myprofile/#{profile.identifier}/cms/destroy/#{t.id}"}
  end

  should 'not display delete button for homepage' do
    login_as(profile.identifier)
    page = profile.home_page
    get :view_page, :profile => profile.identifier, :page => page.explode_path
    assert_no_tag :tag => 'a', :content => 'Delete', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/destroy/#{page.id}" }
  end

  should 'add meta tag to rss feed on view blog' do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    get :view_page, :profile => profile.identifier, :page => [a.path]
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'feed', :href => /\/#{profile.identifier}\/blog\/feed/}
  end

  should 'add meta tag to rss feed on view post blog' do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    t = TextileArticle.create!(:name => 'first post', :parent => a, :profile => profile)
    get :view_page, :profile => profile.identifier, :page => [t.path]
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'feed', :href => /\/#{profile.identifier}\/blog\/feed/}
  end

  should 'link to post with comment form opened' do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    t = TextileArticle.create!(:name => 'first post', :parent => a, :profile => profile)
    get :view_page, :profile => profile.identifier, :page => [a.path]
    assert_tag :tag => 'div', :attributes => { :id => "post-#{t.id}" }, :descendant => { :tag => 'a', :content => 'No comments yet', :attributes => { :href => /#{profile.identifier}\/blog\/first-post\?form=opened#comment_form/ } }
  end

end
