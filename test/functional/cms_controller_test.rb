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
    flunk 'not yet'
  end

  should 'be able to save a save a document' do
    flunk 'not yet'
  end

  should 'be able to set home page' do
    flunk 'pending'
  end

end
