require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user_with_permission('testinguser', 'post_content')
    login_as :testinguser
  end

  attr_reader :profile

  should 'list top level documents on index' do
    get :index, :profile => profile.identifier

    assert_template 'view'
    assert_equal profile, assigns(:profile)
    assert_nil assigns(:article)
    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to view a particular document' do

    a = profile.articles.build(:name => 'blablabla')
    a.save!
    
    get :view, :profile => profile.identifier, :id => a.id

    assert_template 'view'
    assert_equal a, assigns(:article)
    assert_equal [], assigns(:subitems)

    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to edit a document' do
    a = profile.articles.build(:name => 'test')
    a.save!

    get :edit, :profile => profile.identifier, :id => a.id
    assert_template 'edit'
  end

  should 'be able to create a new document' do
    get :new, :profile => profile.identifier
    assert_template 'select_article_type'
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{profile.identifier}/cms/new", :method => /post/i }
  end

  should 'present edit screen after choosing article type' do
    get :new, :profile => profile.identifier, :article_type => 'Article'
    assert_template 'edit'
  end

  should 'be able to save a save a document' do
    assert_difference Article, :count do
      post :new, :profile => profile.identifier, :article => { :name => 'a test article', :body => 'the text of the article ...' }
    end
  end

  should 'be able to set home page' do
    a = profile.articles.build(:name => 'my new home page')
    a.save!
    
    assert_not_equal a, profile.home_page

    post :set_home_page, :profile => profile.identifier, :id => a.id

    assert_redirected_to :action => 'view', :id => a.id

    profile.reload
    assert_equal a, profile.home_page
  end

  should 'set last_changed_by when creating article' do
    login_as(profile.identifier)

    post :new, :profile => profile.identifier, :article => { :name => 'changed by me', :body => 'content ...' }

    a = profile.articles.find_by_path('changed-by-me')
    assert_not_nil a
    assert_equal profile, a.last_changed_by
  end

  should 'set last_changed_by when updating article' do
    other_person = create_user('otherperson').person

    a = profile.articles.build(:name => 'my article')
    a.last_changed_by = other_person
    a.save!
    
    login_as(profile.identifier)
    post :edit, :profile => profile.identifier, :id => a.id, :article => { :body => 'new content for this article' }

    a.reload

    assert_equal profile, a.last_changed_by
  end

  should 'list available editors' do
    editors = [ "#{RAILS_ROOT}/app/controllers/my_profile/cms/bli.rb", "#{RAILS_ROOT}/app/controllers/my_profile/cms/blo.rb" ]
    Dir.expects(:glob).with("#{RAILS_ROOT}/app/controllers/my_profile/cms/*.rb").returns(editors)
    assert_equal editors, CmsController.available_editors
  end

  should 'list available types' do
    editors = [ "#{RAILS_ROOT}/app/controllers/my_profile/cms/text_html.rb", "#{RAILS_ROOT}/app/controllers/my_profile/cms/image.rb" ]
    CmsController.expects(:available_editors).returns(editors)
    assert_equal [ 'text/html', 'image' ], CmsController.available_types
  end

  should 'edit by using the correct template to display the editor depending on the mime-type' do
    a = profile.articles.build(:name => 'test document')
    a.save!
    assert_equal 'text/html', a.mime_type

    get :edit, :profile => profile.identifier, :id => a.id
    assert_response :success
    assert_template 'edit'
  end

  should 'convert mime-types to action names' do
    obj = mock
    obj.extend(CmsHelper)

    assert_equal 'text_html', obj.mime_type_to_action_name('text/html')
    assert_equal 'image', obj.mime_type_to_action_name('image')
    assert_equal 'application_xnoosferosomething', obj.mime_type_to_action_name('application/x-noosfero-something')
  end

  should 'be able to remove article' do
    a = profile.articles.build(:name => 'my-article')
    a.save!

    assert_difference Article, :count, -1 do
      post :destroy, :profile => profile.identifier, :id => a.id
      assert_redirected_to :action => 'index'
    end
  end

end
