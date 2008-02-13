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

  def test_should_display_page
    page = profile.articles.build(:name => 'test')
    page.save!

    uses_host 'anhetegua.net'
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
    assert_match /^text\/xml/, @response.headers['Content-Type']

    assert_equal feed.data, @response.body
  end


end
