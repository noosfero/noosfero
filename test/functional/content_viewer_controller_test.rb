require File.dirname(__FILE__) + '/../test_helper'
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment

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
    assert_match /^text\/xml/, @response.headers['Content-Type']

    assert_equal feed.data, @response.body
  end

  should "display current article's tags" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'test article', :tag_list => 'tag1, tag2')

    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]
    assert_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => {
      :tag => 'a',
      :attributes => { :href => "/profile/#{profile.identifier}/tags/tag1" }
    }
    assert_tag :tag => 'div', :attributes => { :id => 'article-tags' }, :descendant => {
      :tag => 'a',
      :attributes => { :href => "/profile/#{profile.identifier}/tags/tag2" }
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

  should 'show access denied to unpublished articles' do
    profile.articles.create!(:name => 'test', :published => false)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response 403
  end

  should 'show unpublished articles to the user himself' do
    profile.articles.create!(:name => 'test', :published => false)

    login_as(profile.identifier)
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response :success
  end

  should 'not show private content to members' do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)

    folder = fast_create(Folder, :profile_id => community.id, :published => false)
    community.add_member(profile)
    login_as(profile.identifier)

    get :view_page, :profile => community.identifier, :page => [ folder.path ]

    assert_template 'access_denied.rhtml'
  end

  should 'show private content to profile moderators' do
    community = Community.create!(:name => 'testcomm')
    community.articles.create!(:name => 'test', :published => false)
    community.add_moderator(profile)

    login_as(profile.identifier)

    get :view_page, :profile => community.identifier, :page => [ 'test' ]
    assert_response :success
  end

  should 'show private content to profile admins' do
    community = Community.create!(:name => 'testcomm')
    community.articles.create!(:name => 'test', :published => false)
    community.add_admin(profile)

    login_as(profile.identifier)

    get :view_page, :profile => community.identifier, :page => [ 'test' ]
    assert_response :success
  end

  should 'load the correct profile when using hosted domain' do
    profile = create_user('mytestuser').person
    profile.domains << Domain.create!(:name => 'micojones.net')
    profile.save!

    ActionController::TestRequest.any_instance.expects(:host).returns('www.micojones.net').at_least_once

    get :view_page, :page => []

    assert_equal profile, assigns(:profile)
  end

  should 'give link to edit the article for owner' do
    login_as('testinguser')
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end
  should 'not give link to edit the article for non-logged-in people' do
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end
  should 'not give link to edit article for other people' do
    login_as(create_user('anotheruser').login)

    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{@profile.home_page.id}" } }
  end

  should 'give link to create new article' do
    login_as('testinguser')
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end
  should 'give no link to create new article for non-logged in people ' do
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end
  should 'give no link to create new article for other people' do
    login_as(create_user('anotheruser').login)
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new" } }
  end

  should 'give link to create new article inside folder' do
    login_as('testinguser')
    folder = Folder.create!(:name => 'myfolder', :profile => @profile)
    xhr :get, :view_page, :profile => 'testinguser', :page => [ 'myfolder' ], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should 'not give access to private articles if logged off' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :published => false)

    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'access_denied.rhtml'
  end

  should 'not give access to private articles if logged in but not member' do
    login_as('testinguser')
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :published => false)

    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'access_denied.rhtml'
  end

  should 'not give access to private articles if logged in and only member' do
    person = create_user('test_user').person
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :published => false)
    profile.affiliate(person, Profile::Roles.member(profile.environment.id))
    login_as('test_user')

    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'access_denied.rhtml'
  end

  should 'give access to private articles if logged in and moderator' do
    person = create_user('test_user').person
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :published => false)
    profile.affiliate(person, Profile::Roles.moderator(profile.environment.id))
    login_as('test_user')

    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'view_page'
  end

  should 'give access to private articles if logged in and admin' do
    person = create_user('test_user').person
    profile = Profile.create!(:name => 'test profile', :identifier => 'test_profile')
    intranet = Folder.create!(:name => 'my_intranet', :profile => profile, :published => false)
    profile.affiliate(person, Profile::Roles.admin(profile.environment.id))
    login_as('test_user')

    get :view_page, :profile => 'test_profile', :page => [ 'my-intranet' ]

    assert_template 'view_page'
  end

  should 'list comments if article has them, even if new comments are not allowed' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)
    page.comments.create!(:author => profile, :title => 'list my comment', :body => 'foo bar baz')
    get :view_page, :profile => profile.identifier, :page => ['myarticle']

    assert_tag :content => /list my comment/
  end

  should 'show link to publication on view' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    login_as(profile.identifier)

    xhr :get, :view_page, :profile => profile.identifier, :page => ['myarticle'], :toolbar => true

    assert_tag :tag => 'a', :attributes => {:href => ('/myprofile/' + profile.identifier + '/cms/publish/' + page.id.to_s)}
  end

  should 'not show link to publication on view if not on person profile' do
    prof = Community.create!(:name => 'test comm', :identifier => 'test_comm')
    page = prof.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    prof.affiliate(profile, Profile::Roles.all_roles(prof.environment.id))
    login_as(profile.identifier)

    xhr :get, :view_page, :profile => prof.identifier, :page => ['myarticle'], :toolbar => true

    assert_no_tag :tag => 'a', :attributes => {:href => ('/myprofile/' + prof.identifier + '/cms/publish/' + page.id.to_s)}
  end

  should 'redirect to new article path under an old path' do
    p = create_user('test_user').person
    a = p.articles.create(:name => 'old-name')
    old_path = a.explode_path
    a.name = 'new-name'
    a.save!

    get :view_page, :profile => p.identifier, :page => old_path

    assert_response :redirect
    assert_redirected_to :host => p.default_hostname, :controller => 'content_viewer', :action => 'view_page', :profile => p.identifier, :page => a.explode_path
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
    assert_redirected_to :host => p.default_hostname, :controller => 'content_viewer', :action => 'view_page', :profile => p.identifier, :page => a2.explode_path
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

    current = fast_create(Environment, :name => 'test environment')
    current.domains.create!(:name => 'example.com')
    uses_host 'www.example.com'

    get :view_page, :profile => 'mytestprofile', :page => []
    assert_response :missing
  end

  should 'list unpublished posts to owner with a different class' do
    login_as('testinguser')
    blog = Blog.create!(:name => 'A blog test', :profile => profile)
    blog.posts << TextileArticle.create!(:name => 'Post', :profile => profile, :parent => blog, :published => false)

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_tag :tag => 'div', :attributes => {:class => /not-published/}
  end

  should 'not list unpublished posts to a not logged person' do
    blog = Blog.create!(:name => 'A blog test', :profile => profile)
    blog.posts << TextileArticle.create!(:name => 'Post', :profile => profile, :parent => blog, :published => false)

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_no_tag :tag => 'a', :content => "Post"
  end

  should 'display pagination links of blog' do
    blog = Blog.create!(:name => 'A blog test', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      blog.posts << TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => blog)
    end
    assert_equal 10, blog.posts.size

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_tag :tag => 'a', :attributes => { :href => "/#{profile.identifier}/#{blog.path}?npage=2", :rel => 'next' }
  end

  should 'display first page of blog posts' do
    blog = Blog.create!(:name => 'My blog', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      blog.children << TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => blog)
    end
    assert_equal 10, blog.posts.size

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    for n in 1..5
      assert_no_tag :tag => 'h1', :attributes => { :class => 'title' }, :descendant => {:tag => 'a', :attributes => {:href => /\/#{profile.identifier}\/my-blog\/post-#{n}/}, :content => "Post #{n}"}
    end
    for n in 6..10
      assert_tag :tag => 'h1', :attributes => { :class => 'title' }, :descendant => {:tag => 'a', :attributes => {:href => /\/#{profile.identifier}\/my-blog\/post-#{n}/}, :content => "Post #{n}"}
    end
  end

  should 'display others pages of blog posts' do
    blog = Blog.create!(:name => 'My blog', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      blog.children << TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => blog)
    end
    assert_equal 10, blog.posts.size

    get :view_page, :profile => profile.identifier, :page => [blog.path], :npage => 2
    for n in 1..5
      assert_tag :tag => 'h1', :attributes => { :class => 'title' }, :descendant => {:tag => 'a', :attributes => {:href => /\/#{profile.identifier}\/my-blog\/post-#{n}/}, :content => "Post #{n}"}
    end
    for n in 6..10
      assert_no_tag :tag => 'h1', :attributes => { :class => 'title' }, :descendant => {:tag => 'a', :attributes => {:href => /\/#{profile.identifier}\/my-blog\/post-#{n}/}, :content => "Post #{n}"}
    end
  end

  should 'set year and month filter from URL params' do
    blog = Blog.create!(:name => "blog", :profile => profile)
    profile.articles << blog

    past_post = TextileArticle.create!(:name => "past post", :profile => profile, :parent => blog, :published_at => blog.created_at - 1.year)
    current_post = TextileArticle.create!(:name => "current post", :profile => profile, :parent => blog)
    blog.children << past_post
    blog.children << current_post

    year, month = profile.blog.created_at.year.to_s, '%02d' % profile.blog.created_at.month

    get :view_page, :profile => profile.identifier, :page => [profile.blog.path], :year => year, :month => month

    assert_no_tag :tag => 'a', :content => past_post.title
    assert_tag :tag => 'a', :content => current_post.title
  end

  should 'give link to create new article inside folder when view child of folder' do
    login_as('testinguser')
    folder = Folder.create!(:name => 'myfolder', :profile => @profile)
    folder.children << TextileArticle.new(:name => 'children-article', :profile => @profile)
    xhr :get, :view_page, :profile => 'testinguser', :page => [ 'myfolder', 'children-article' ], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should "display 'New article' when create children of folder" do
    login_as(profile.identifier)
    a = Folder.new(:name => 'article folder'); profile.articles << a;  a.save!
    Article.stubs(:short_description).returns('bli')
    xhr :get, :view_page, :profile => profile.identifier, :page => [a.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'New article'
  end

  should "display 'New post' when create children of blog" do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    xhr :get, :view_page, :profile => profile.identifier, :page => [a.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'New post'
  end

  should "display same label for new article button of parent" do
    login_as(profile.identifier)
    a = Blog.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    t = TextileArticle.create!(:name => 'first post', :parent => a, :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => [t.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'New post'
  end

  should 'display button to remove article' do
    login_as(profile.identifier)
    t = TextileArticle.create!(:name => 'article to destroy', :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => [t.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'Delete', :attributes => {:href => "/myprofile/#{profile.identifier}/cms/destroy/#{t.id}"}
  end

  should 'not display delete button for homepage' do
    login_as(profile.identifier)
    page = profile.home_page
    xhr :get, :view_page, :profile => profile.identifier, :page => page.explode_path, :toolbar => true
    assert_no_tag :tag => 'a', :content => 'Delete', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/destroy/#{page.id}" }
  end

  should 'add meta tag to rss feed on view blog' do
    login_as(profile.identifier)
    profile.articles << Blog.new(:name => 'Blog', :profile => profile)
    get :view_page, :profile => profile.identifier, :page => ['blog']
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'Blog', :href => "http://#{environment.default_hostname}/testinguser/blog/feed" }
  end

  should 'add meta tag to rss feed on view post blog' do
    login_as(profile.identifier)
    blog = Blog.create!(:name => 'Blog', :profile => profile)
    TextileArticle.create!(:name => 'first post', :parent => blog, :profile => profile)
    get :view_page, :profile => profile.identifier, :page => ['blog', 'first-post']
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'Blog', :href => "http://#{environment.default_hostname}/testinguser/blog/feed" }
  end

  should 'hit the article when viewed' do
    a = profile.articles.create!(:name => 'test article')
    get :view_page, :profile => profile.identifier, :page => [a.path]
    a.reload
    assert_equal 1, a.hits
  end

  should 'render html for image when view' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)
    get :view_page, :profile => profile.identifier, :page => file.explode_path, :view => true

    assert_response :success
    assert_template 'view_page'
  end

  should 'download data for image when not view' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)
    get :view_page, :profile => profile.identifier, :page => file.explode_path

    assert_response :success
    assert_template nil
  end

  should "display 'Upload files' when create children of image gallery" do
    login_as(profile.identifier)
    f = Gallery.create!(:name => 'gallery', :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => f.explode_path, :toolbar => true
    assert_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{f.id}/}
  end

  should "display 'New article' when showing folder child of image gallery" do
    login_as(profile.identifier)
    folder1 = Gallery.create!(:name => 'gallery1', :profile => profile)
    folder1.children << folder2 = Folder.new(:name => 'gallery2', :profile => profile)

    xhr :get, :view_page, :profile => profile.identifier, :page => folder2.explode_path, :toolbar => true
    assert_tag :tag => 'a', :content => 'New article', :attributes => {:href =>/parent_id=#{folder2.id}/}
  end

  should "display 'Upload files' to image gallery when showing its children" do
    login_as(profile.identifier)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)
    file = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    xhr :get, :view_page, :profile => profile.identifier, :page => file.explode_path, :view => true, :toolbar => true

    assert_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{folder.id}/}
  end

  should 'render slideshow template' do
    f = Folder.create!(:name => 'gallery', :profile => profile)
    get :view_page, :profile => profile.identifier, :page => f.explode_path, :slideshow => true

    assert_template 'slideshow'
  end

  should 'display all images from profile in the slideshow' do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)

    image1 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'))
    image2 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    get :view_page, :profile => profile.identifier, :page => folder.explode_path, :slideshow => true

    assert_equal 2, assigns(:images).size
  end

  should 'display default image in the slideshow if thumbnails were not processed' do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)

    image1 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'))

    get :view_page, :profile => profile.identifier, :page => folder.explode_path, :slideshow => true

    assert_tag :tag => 'img', :attributes => {:src => /\/images\/icons-app\/image-loading-display.png/}
  end

  should 'display thumbnail image in the slideshow if thumbnails were processed' do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)

    image1 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'))

    process_delayed_job_queue
    get :view_page, :profile => profile.identifier, :page => folder.explode_path, :slideshow => true

    assert_tag :tag => 'img', :attributes => {:src => /other-pic_display.jpg/}
  end

  should 'display default image in gallery if thumbnails were not processed' do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)

    image1 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'))

    get :view_page, :profile => profile.identifier, :page => folder.explode_path

    assert_tag :tag => 'a', :attributes => {:class => 'image', :style => /background-image: url\(\/images\/icons-app\/image-loading-thumb.png\)/}
  end

  should 'display thumbnail image in gallery if thumbnails were processed' do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(:name => 'gallery', :profile => profile)

    image1 = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'))

    process_delayed_job_queue
    get :view_page, :profile => profile.identifier, :page => folder.explode_path

    assert_tag :tag => 'a', :attributes => {:class => 'image', :style => /background-image: url\(.*\/other-pic_thumb.jpg\)/}
  end

  should 'display source from article' do
    profile.articles << TextileArticle.new(:name => "Article one", :profile => profile, :source => 'http://www.original-source.invalid')
    get :view_page, :profile => profile.identifier, :page => ['article-one']
    assert_tag :tag => 'div', :attributes => { :id => 'article-source' }, :content => /http:\/\/www.original-source.invalid/
  end

  should 'not display source if article has no source' do
    profile.articles << TextileArticle.new(:name => "Article one", :profile => profile)
    get :view_page, :profile => profile.identifier, :page => ['article-one']
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-source' }
  end

  should 'redirect to profile controller when there is no homepage' do
    profile.home_page.destroy
    get :view_page, :profile => profile.identifier, :page => []
    assert_redirected_to :controller => 'profile', :action => 'index', :profile => profile.identifier
  end

  should "not display 'Upload files' when viewing blog" do
    login_as(profile.identifier)
    b = Blog.create!(:name => 'article folder', :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => b.explode_path, :toolbar => true
    assert_no_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{b.id}/}
  end

  should "not display 'Upload files' when viewing post from a blog" do
    login_as(profile.identifier)
    b = Blog.create!(:name => 'article folder', :profile => profile)
    blog_post = TextileArticle.create!(:name => 'children-article', :profile => profile, :parent => b)
    xhr :get, :view_page, :profile => profile.identifier, :page => blog_post.explode_path, :toolbar => true
    assert_no_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{b.id}/}
  end

  should 'display title of image on image gallery' do
    login_as(profile.identifier)
    folder = fast_create(Gallery, :profile_id => profile.id)
    file = UploadedFile.create!(:title => 'my img title', :profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    get :view_page, :profile => profile.identifier, :page => folder.explode_path

    assert_tag :tag => 'li', :attributes => {:title => 'my img title', :class => 'image-gallery-item'}, :child => {:tag => 'span', :content => 'my img title'}
  end

  should 'not allow html on title of the images' do
    login_as(profile.identifier)
    folder = fast_create(Gallery, :profile_id => profile.id)
    file = UploadedFile.create!(:title => '<b>my img title</b>', :profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    get :view_page, :profile => profile.identifier, :page => folder.explode_path

    assert_tag :tag => 'li', :attributes => {:title => 'my img title', :class => 'image-gallery-item'}, :child => {:tag => 'span', :content => 'my img title'}
  end

  should 'allow publisher owner view private articles' do
    c = Community.create!(:name => 'test_com')
    u = create_user_with_permission('test_user', 'publish_content', c)
    login_as u.identifier
    a = c.articles.create!(:name => 'test-article', :last_changed_by => u, :published => false)

    get :view_page, :profile => c.identifier, :page => a.explode_path

    assert_response :success
    assert_template 'view_page'
  end

  should 'display link to new_article if profile is publisher' do
    c = Community.create!(:name => 'test_com')
    u = create_user_with_permission('test_user', 'publish_content', c)
    login_as u.identifier
    a = c.articles.create!(:name => 'test-article', :last_changed_by => profile, :published => true)

    xhr :get, :view_page, :profile => c.identifier, :page => a.explode_path, :toolbar => true

    assert_tag :tag => 'a', :content => 'New article'
  end

  should 'display message if user was removed' do
    article = profile.articles.create(:name => 'comment test')
    to_be_removed = create_user('removed_user').person
    comment = article.comments.create(:author => to_be_removed, :title => 'Test Comment', :body => 'My author does not exist =(')
    to_be_removed.destroy

    get :view_page, :profile => profile.identifier, :page => article.explode_path

    assert_tag :tag => 'span', :content => '(removed user)', :attributes => {:class => 'comment-user-status icon-user-removed'}
  end

  should 'show only first paragraph of blog posts if visualization_format is short' do
    login_as(profile.identifier)

    blog = Blog.create!(:name => 'A blog test', :profile => profile, :visualization_format => 'short')

    blog.posts << TinyMceArticle.create!(:name => 'first post', :parent => blog, :profile => profile, :body => '<p>Content to be displayed.</p> Anything')

    get :view_page, :profile => profile.identifier, :page => blog.explode_path

    assert_tag :tag => 'div', :attributes => { :class => 'short-post'}, :content => /Content to be displayed./
    assert_no_tag :tag => 'div', :attributes => { :class => 'short-post'}, :content => /Anything/
  end

  should 'display link to edit blog for allowed' do
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    login_as(profile.identifier)
    xhr :get, :view_page, :profile => profile.identifier, :page => blog.explode_path, :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{blog.id}" }, :content => 'Configure blog' }
  end

  # Forum

  should 'list unpublished forum posts to owner with a different class' do
    login_as('testinguser')
    forum = Forum.create!(:name => 'A forum test', :profile => profile)
    forum.posts << TextileArticle.create!(:name => 'Post', :profile => profile, :parent => forum, :published => false)

    get :view_page, :profile => profile.identifier, :page => [forum.path]
    assert_tag :tag => 'tr', :attributes => {:class => /not-published/}
  end

  should 'not list unpublished forum posts to a not logged person' do
    forum = Forum.create!(:name => 'A forum test', :profile => profile)
    forum.posts << TextileArticle.create!(:name => 'Post', :profile => profile, :parent => forum, :published => false)

    get :view_page, :profile => profile.identifier, :page => [forum.path]
    assert_no_tag :tag => 'a', :content => "Post"
  end

  should 'display pagination links of forum' do
    forum = Forum.create!(:name => 'A forum test', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      forum.posts << TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => forum)
    end
    assert_equal 10, forum.posts.size

    get :view_page, :profile => profile.identifier, :page => [forum.path]
    assert_tag :tag => 'a', :attributes => { :href => "/#{profile.identifier}/#{forum.path}?npage=2", :rel => 'next' }
  end

  should 'display first page of forum posts' do
    forum = Forum.create!(:name => 'My forum', :profile => profile, :posts_per_page => 5)
    for n in 1..10
      art = TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => forum)
      art.updated_at = (10 - n).days.ago
      art.stubs(:record_timestamps).returns(false)
      art.save!
    end
    assert_equal 10, forum.posts.size

    get :view_page, :profile => profile.identifier, :page => [forum.path]
    for n in 1..5
      assert_no_tag :tag => 'a', :content => "Post #{n}", :parent => { :tag => 'td', :parent => { :tag => 'tr', :attributes => { :class => /forum-post/ } } }
    end
    for n in 6..10
      assert_tag :tag => 'a', :content => "Post #{n}", :parent => { :tag => 'td', :parent => { :tag => 'tr', :attributes => { :class => /forum-post/ } } }
    end
  end

  should 'display others pages of forum posts' do
    forum = Forum.create!(:name => 'My forum', :profile => profile, :posts_per_page => 5)
    now = Time.now
    for n in 1..10
      Time.stubs(:now).returns(now - 10.days + n.days)
      forum.children << art = TextileArticle.create!(:name => "Post #{n}", :profile => profile, :parent => forum)
    end
    assert_equal 10, forum.posts.size

    get :view_page, :profile => profile.identifier, :page => [forum.path], :npage => 2
    for n in 1..5
      assert_tag :tag => 'a', :content => "Post #{n}", :parent => { :tag => 'td', :parent => { :tag => 'tr', :attributes => { :class => /forum-post/ } } }
    end
    for n in 6..10
      assert_no_tag :tag => 'a', :content => "Post #{n}", :parent => { :tag => 'td', :parent => { :tag => 'tr', :attributes => { :class => /forum-post/ } } }
    end
  end

  should 'set year and month filter from URL params for forum' do
    forum = Forum.create!(:name => "forum", :profile => profile)
    profile.articles << forum

    past_post = TextileArticle.create!(:name => "past post", :profile => profile, :parent => forum, :published_at => forum.created_at - 1.year)
    current_post = TextileArticle.create!(:name => "current post", :profile => profile, :parent => forum)
    forum.children << past_post
    forum.children << current_post

    year, month = forum.created_at.year.to_s, '%02d' % forum.created_at.month

    get :view_page, :profile => profile.identifier, :page => [profile.forum.path], :year => year, :month => month

    assert_no_tag :tag => 'a', :content => past_post.title
    assert_tag :tag => 'a', :content => current_post.title
  end

  should "display 'New discussion topic' when create children of forum" do
    login_as(profile.identifier)
    a = Forum.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    xhr :get, :view_page, :profile => profile.identifier, :page => [a.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'New discussion topic'
  end

  should "display same label for new article button of forum parent" do
    login_as(profile.identifier)
    a = Forum.create!(:name => 'article folder', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    t = TextileArticle.create!(:name => 'first post', :parent => a, :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => [t.path], :toolbar => true
    assert_tag :tag => 'a', :content => 'New discussion topic'
  end

  should 'add meta tag to rss feed on view forum' do
    login_as(profile.identifier)
    profile.articles << Forum.new(:name => 'Forum', :profile => profile)
    get :view_page, :profile => profile.identifier, :page => ['forum']
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'Forum', :href => "http://#{environment.default_hostname}/testinguser/forum/feed" }
  end

  should 'add meta tag to rss feed on view post forum' do
    login_as(profile.identifier)
    profile.articles << Forum.new(:name => 'Forum', :profile => profile)
    profile.forum.posts << TextileArticle.new(:name => 'first post', :parent => profile.forum, :profile => profile)
    get :view_page, :profile => profile.identifier, :page => ['forum', 'first-post']
    assert_tag :tag => 'link', :attributes => { :rel => 'alternate', :type => 'application/rss+xml', :title => 'Forum', :href => "http://#{environment.default_hostname}/testinguser/forum/feed" }
  end

  should "not display 'Upload files' when viewing forum" do
    login_as(profile.identifier)
    b = Forum.create!(:name => 'article folder', :profile => profile)
    xhr :get, :view_page, :profile => profile.identifier, :page => b.explode_path, :toolbar => true
    assert_no_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{b.id}/}
  end

  should "not display 'Upload files' when viewing post from a forum" do
    login_as(profile.identifier)
    b = Forum.create!(:name => 'article folder', :profile => profile)
    forum_post = TextileArticle.create!(:name => 'children-article', :profile => profile, :parent => b)
    xhr :get, :view_page, :profile => profile.identifier, :page => forum_post.explode_path, :toolbar => true
    assert_no_tag :tag => 'a', :content => 'Upload files', :attributes => {:href => /parent_id=#{b.id}/}
  end

  should 'display link to edit forum for allowed' do
    forum = fast_create(Forum, :profile_id => profile.id, :path => 'forum')
    login_as(profile.identifier)
    xhr :get, :view_page, :profile => profile.identifier, :page => forum.explode_path, :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{forum.id}" }, :content => 'Configure forum' }
  end

  should 'display add translation link if article is translatable' do
    login_as @profile.identifier
    textile = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'textile', :language => 'en')
    xhr :get, :view_page, :profile => @profile.identifier, :page => textile.explode_path, :toolbar => true
    assert_tag :a, :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?article%5Btranslation_of_id%5D=#{textile.id}&amp;type=#{TextileArticle}" }
  end

  should 'not display add translation link if article is not translatable' do
    login_as @profile.identifier
    blog = fast_create(Blog, :profile_id => @profile.id, :path => 'blog')
    xhr :get, :view_page, :profile => @profile.identifier, :page => blog.explode_path, :toolbar => true
    assert_no_tag :a, :attributes => { :content => 'Add translation', :class => /icon-locale/ }
  end

  should 'not display add translation link if article hasnt a language defined' do
    login_as @profile.identifier
    textile = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'textile')
    xhr :get, :view_page, :profile => @profile.identifier, :page => textile.explode_path, :toolbar => true
    assert_no_tag :a, :attributes => { :content => 'Add translation', :class => /icon-locale/ }
  end

  should 'display translations link if article has translations' do
    login_as @profile.identifier
    textile     = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'textile', :language => 'en')
    translation = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'translation', :language => 'es', :translation_of_id => textile)
    xhr :get, :view_page, :profile => @profile.identifier, :page => textile.explode_path, :toolbar => true
    assert_tag :a, :attributes => { :class => /article-translations-menu/, :onmouseover => /toggleSubmenu/ }
  end

  should 'not be redirected if already in translation' do
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en')
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :translation_of_id => en_article)
    @request.env['HTTP_REFERER'] = "http://localhost:3000/#{@profile.identifier}/#{es_article.path}"
    FastGettext.stubs(:locale).returns('es')
    get :view_page, :profile => @profile.identifier, :page => es_article.explode_path
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should 'not be redirected if article does not have a language' do
    FastGettext.stubs(:locale).returns('es')
    article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'article')
    get :view_page, :profile => @profile.identifier, :page => article.explode_path
    assert_response :success
    assert_equal article, assigns(:page)
  end

  should 'not be redirected if http_referer is a translation' do
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en')
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :translation_of_id => en_article)
    @request.env['HTTP_REFERER'] = "http://localhost:3000/#{@profile.identifier}/#{es_article.path}"
    FastGettext.stubs(:locale).returns('es')
    get :view_page, :profile => @profile.identifier, :page => en_article.explode_path
    assert_response :success
    assert_equal en_article, assigns(:page)
  end

  should 'not be redirected to transition if came from edit' do
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en')
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :translation_of_id => en_article)
    FastGettext.stubs(:locale).returns('es')
    @request.env['HTTP_REFERER'] = "http://localhost/myprofile/#{@profile.identifier}/cms/edit/#{en_article.id}"
    get :view_page, :profile => @profile.identifier, :page => es_article.explode_path
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should 'not be redirected to transition if came from new' do
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en')
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :translation_of_id => en_article)
    FastGettext.stubs(:locale).returns('es')
    @request.env['HTTP_REFERER'] = "http://localhost/myprofile/#{@profile.identifier}/cms/new"
    get :view_page, :profile => @profile.identifier, :page => es_article.explode_path
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should 'replace article for his translation at blog listing if blog option is enabled' do
    FastGettext.stubs(:locale).returns('es')
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    blog.display_posts_in_current_language = true
    blog.save
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en', :parent_id => blog.id)
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :parent_id => blog.id, :translation_of_id => en_article)

    get :view_page, :profile => @profile.identifier, :page => blog.explode_path
    assert_tag :div, :attributes => { :id => "post-#{es_article.id}" }
    assert_no_tag :div, :attributes => { :id => "post-#{en_article.id}" }
  end

  should 'not display article at blog listing if blog option is enabled and there is no translation for the language' do
    FastGettext.stubs(:locale).returns('pt')
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    blog.display_posts_in_current_language = true
    blog.save
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en', :parent_id => blog.id)
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :parent_id => blog.id, :translation_of_id => en_article)
    pt_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'pt', :parent_id => blog.id, :translation_of_id => en_article)

    en_article2 = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en', :parent_id => blog.id)
    es_article2 = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :parent_id => blog.id, :translation_of_id => en_article2)


    get :view_page, :profile => @profile.identifier, :page => blog.explode_path

    assert_equal [pt_article], assigns(:posts)
  end

  should 'list all posts at blog listing if blog option is disabled' do
    FastGettext.stubs(:locale).returns('es')
    blog = Blog.create!(:name => 'A blog test', :profile => profile, :display_posts_in_current_language => false)
    blog.posts << es_post = TextileArticle.create!(:name => 'Spanish Post', :profile => profile, :parent => blog, :language => 'es')
    blog.posts << en_post = TextileArticle.create!(:name => 'English Post', :profile => profile, :parent => blog, :language => 'en', :translation_of_id => es_post.id)
    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_equal 2, assigns(:posts).size
    assert_tag :div, :attributes => { :id => "post-#{es_post.id}" }
    assert_tag :div, :attributes => { :id => "post-#{en_post.id}" }
  end

  should 'display only native translations at blog listing if blog option is enabled' do
    FastGettext.stubs(:locale).returns('es')
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    blog.display_posts_in_current_language = true
    blog.save!
    en_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en', :parent_id => blog.id)
    es_article = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :parent_id => blog.id, :translation_of_id => en_article)
    blog.posts = [en_article, es_article]

    get :view_page, :profile => @profile.identifier, :page => blog.explode_path
    assert_equal [es_article], assigns(:posts)
  end

  should 'display reply to comment button if authenticated' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    Comment.destroy_all
    comment = Comment.create!(:author => profile, :title => 'a comment', :body => 'lalala', :article => article)
    login_as 'testuser'
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_tag :tag => 'a', :attributes => { :class => /comment-actions-reply/ }
  end

  should 'display reply to comment button if not authenticated' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_tag :tag => 'a', :attributes => { :class => /comment-actions-reply/ }
  end

  should 'display replies if comment has replies' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment1 = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment1.save!
    comment2 = article.comments.build(:author => profile, :title => 'a comment', :body => 'replying to lalala', :reply_of_id => comment1.id)
    comment2.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_tag :tag => 'ul', :attributes => { :class => 'comment-replies' }
  end

  should 'not display replies if comment does not have replies' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = article.comments.build(:author => profile, :title => 'a comment', :body => 'lalala')
    comment.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_no_tag :tag => 'ul', :attributes => { :class => 'comment-replies' }
  end

  should 'add an zero width space every 4 caracters of comment urls' do
    url = 'www.an.url.to.be.splited.com'
    a = fast_create(TextileArticle, :profile_id => @profile.id, :path => 'textile', :language => 'en')
    c = a.comments.create!(:author => @profile, :title => 'An url', :body => url)
    get :view_page, :profile => @profile.identifier, :page => [ 'textile' ]
    assert_tag :a, :attributes => { :href => "http://" + url}, :content => url.scan(/.{4}/).join('&#x200B;')
  end

  should 'not show a post comment button on top if there is only one comment' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    Comment.destroy_all
    article.save!
    comment = article.comments.build(:author => profile, :title => 'hi', :body => 'hello')
    comment.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_no_tag :tag => 'a', :attributes => { :id => 'top-post-comment-button' }
  end

  should 'not show a post comment button on top if there are no comments' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    Comment.destroy_all
    article.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_no_tag :tag => 'a', :attributes => { :id => 'top-post-comment-button' }
  end

  should 'show a post comment button on top if there are at least two comments' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    Comment.destroy_all
    article.save!
    comment1 = article.comments.build(:author => profile, :title => 'hi', :body => 'hello')
    comment1.save!
    comment2 = article.comments.build(:author => profile, :title => 'hi', :body => 'hello')
    comment2.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_tag :tag => 'a', :attributes => { :id => 'top-post-comment-button' }
  end

  should 'not show a post comment button on top if there are one comment and one reply' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    Comment.destroy_all
    article.save!
    comment1 = article.comments.build(:author => profile, :title => 'hi', :body => 'hello')
    comment1.save!
    comment2 = article.comments.build(:author => profile, :title => 'hi', :body => 'hello', :reply_of_id => comment1.id)
    comment2.save!
    get :view_page, :profile => 'testuser', :page => [ 'test' ]
    assert_no_tag :tag => 'a', :attributes => { :id => 'top-post-comment-button' }
  end

  should 'suggest article link displayed into article-actions div' do
    community = fast_create(Community)
    blog = fast_create(Blog, :profile_id => community.id, :path => 'blog')
    xhr :get, :view_page, :profile => community.identifier, :page => [ 'blog' ], :toolbar => true
    assert_tag :tag => 'a', :attributes => { :id => 'suggest-article-link' }
  end

  should 'render toolbar when it is an ajax request' do
    community = fast_create(Community)
    blog = fast_create(Blog, :profile_id => community.id, :path => 'blog')
    xhr :get, :view_page, :profile => community.identifier, :page => ['blog'], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-header' }
  end

  should 'add class to body tag if is on profile homepage' do
    profile = fast_create(Profile)
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    profile.home_page = blog
    profile.save
    get :view_page, :profile => profile.identifier, :page => ['blog']
    assert_tag :tag => 'body', :attributes => { :class => /profile-homepage/ }
  end

  should 'not add class to body tag if is not on profile homepage' do
    profile = fast_create(Profile)
    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog')
    get :view_page, :profile => profile.identifier, :page => ['blog']
    assert_no_tag :tag => 'body', :attributes => { :class => /profile-homepage/ }
  end

  should 'not display article actions button if any plugins says so' do
    class Plugin1 < Noosfero::Plugin
      def content_remove_edit(content); true; end
    end
    class Plugin2 < Noosfero::Plugin
      def content_remove_edit(content); false; end
    end

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    login_as('testinguser')
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_no_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :href => "/myprofile/testinguser/cms/edit/#{profile.home_page.id}" } }
  end

  should 'expire article actions button if any plugins says so' do
    class Plugin1 < Noosfero::Plugin
      def content_expire_edit(content); 'This button is expired.'; end
    end
    class Plugin2 < Noosfero::Plugin
      def content_expire_edit(content); nil; end
    end

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    login_as('testinguser')
    xhr :get, :view_page, :profile => 'testinguser', :page => [], :toolbar => true
    assert_tag :tag => 'div', :attributes => { :id => 'article-actions' }, :descendant => { :tag => 'a', :attributes => { :title => 'This button is expired.', :class => 'button with-text icon-edit disabled' } }
  end

  should 'remove email from article followers when unfollow' do
    profile = create_user('testuser').person
    follower_email = 'john@doe.br'
    article = profile.articles.create(:name => 'test')
    article.followers = [follower_email]
    article.save

    assert_includes Article.find(article.id).followers, follower_email
    post :view_page, :profile => profile.identifier, :page => [article.name], :unfollow => 'commit', :email => follower_email
    assert_not_includes Article.find(article.id).followers, follower_email
  end

  should 'not display comments marked as spam' do
    article = fast_create(Article, :profile_id => profile.id)
    ham = fast_create(Comment, :source_id => article.id, :source_type => 'Article', :title => 'some content')
    spam = fast_create(Comment, :source_id => article.id, :source_type => 'Article', :spam => true, :title => 'this is a spam')

    get 'view_page', :profile => profile.identifier, :page => article.path.split('/')
    assert_no_tag :tag => 'h4', :content => /spam/
  end

  should 'add extra content on comment form from plugins' do
    class Plugin1 < Noosfero::Plugin
      def comment_form_extra_contents(args)
        lambda {
          hidden_field_tag('comment[some_field_id]', 1)
         }
      end
    end
    class Plugin2 < Noosfero::Plugin
      def comment_form_extra_contents(args)
        lambda {
          hidden_field_tag('comment[another_field_id]', 1)
         }
      end
    end

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    get :view_page, :profile => profile.identifier, :page => [ 'myarticle' ]

    assert_tag :tag => 'input', :attributes => {:name => 'comment[some_field_id]', :type => 'hidden'}
    assert_tag :tag => 'input', :attributes => {:name => 'comment[another_field_id]', :type => 'hidden'}
  end

  should 'filter comments with scope defined by the plugins' do
    class Plugin1 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(:user_agent => 'Jack')
      end
    end

    class Plugin2 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(:referrer => 'kernel.org')
      end
    end

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    c1 = fast_create(Comment, :source_id => article.id, :user_agent => 'Jack', :referrer => 'kernel.org')
    c2 = fast_create(Comment, :source_id => article.id, :user_agent => 'Rose', :referrer => 'kernel.org')
    c3 = fast_create(Comment, :source_id => article.id, :user_agent => 'Jack', :referrer => 'google.com')

    get :view_page, :profile => profile.identifier, :page => [ article.path ]

    assert_includes assigns(:comments), c1
    assert_not_includes assigns(:comments), c2
    assert_not_includes assigns(:comments), c3
  end

  should 'display pagination links of comments' do
    article = fast_create(Article, :profile_id => profile.id)
    for n in 1..15
      article.comments.create!(:author => profile, :title => "some title #{n}", :body => 'some body #{n}')
    end
    assert_equal 15, article.comments.count

    get 'view_page', :profile => profile.identifier, :page => article.path.split('/')
    assert_tag :tag => 'a', :attributes => { :href => "/#{profile.identifier}/#{article.path}?comment_page=2", :rel => 'next' }
  end 

  should 'not escape acceptable HTML in list of blog posts' do
    login_as('testinguser')
    blog = Blog.create!(:name => 'A blog test', :profile => profile)
    blog.posts << TinyMceArticle.create!(
      :name => 'Post',
      :profile => profile,
      :parent => blog,
      :published => true,
      :body => "<p>This is a <strong>bold</strong> statement right there!</p>"
    )

    get :view_page, :profile => profile.identifier, :page => [blog.path]
    assert_tag :tag => 'strong', :content => /bold/
  end

  should 'display link to download of non-recognized file types on its page' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'bin/unknown'), :profile => profile)
    get :view_page, file.url.merge(:view=>:true)
    assert_tag :tag => 'a',
               :content => file.filename,
               :attributes => { :href => file.public_filename }
  end

end
