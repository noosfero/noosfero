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

    @profile = create_user('testinguser').person
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
    flunk 'pending'
  end

  should 'be able to save a save a document' do
    flunk 'pending'
  end

  should 'be able to set home page' do
    flunk 'pending'
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

  should 'made the editor actions available' do
    # ASSUMING that 'text/html' is always available and has 'new' and 'edit'
    assert CmsController.instance_methods.include?('text_html_new')
    assert CmsController.instance_methods.include?('text_html_edit')
  end

  should 'edit by redirecting to the correct editor depending on the mime-type' do
    a = profile.articles.build(:name => 'test document')
    a.save!
    assert_equal 'text/html', a.mime_type

    get :edit, :profile => profile.identifier, :id => a.id
    assert_redirected_to :action => 'text_html_edit', :id => a.id
  end

end
