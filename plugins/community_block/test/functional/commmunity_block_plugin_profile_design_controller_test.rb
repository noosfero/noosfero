require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  def rescue_action(e)
    raise e
  end
end

class ProfileControllerTest < ActionController::TestCase

  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @user = create_user('testinguser').person
    login_as(@user.identifier)

    @community = fast_create(Community, :environment_id => Environment.default)
    @community.add_member @user
    @community.add_admin @user

    @environment = @community.environment
    @environment.enabled_plugins = ['CommunityBlock']
    @environment.save!

    CommunityBlock.delete_all
    @box1 = Box.create!(:owner => @community)
    @community.boxes = [@box1]

    @block = CommunityBlock.new
    @block.box = @box1
    @block.save!

    @community.blocks<<@block
    @community.save!
  end

  should 'display community-block' do
    get :index, :profile => @community.identifier
    assert_tag :div, :attributes => {:class => 'community-block-logo'}
    assert_tag :div, :attributes => {:class => 'community-block-info'}
    assert_tag :h1, :attributes => {:class => 'community-block-title'}
    assert_tag :div, :attributes => {:class => 'community-block-description'}
    assert_tag :div, :attributes => {:class => 'community-block-buttons'}
  end


  # USER LOGGED IN AND COMMUNITY MEMBER #

  should 'display *leave* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-remove'}
  end

  should 'display *send email to administrators* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-menu-mail'}
  end

  should 'display *report* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-alert report-abuse-action'}
  end

  
  # USER LOGGED IN AND NOT MEMBER OF THE COMMUNITY

  should 'display *join* button when the user is logged in and is not a member of the community' do
    @community.remove_member @user
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-add'}
  end

  should 'display *send email to administrators* button when the user is logged in and is not a member of the community' do
    @community.remove_member @user
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-menu-mail'}
  end

  should 'display *report* button when the user is logged in and is not a member of the community' do
    @community.remove_member @user
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-alert report-abuse-action'}
  end


  # USER LOGGED IN AND COMMUNITY ADMIN

  should 'display *configure* button when the user is logged in and is community admin' do
    get :index, :profile => @community.identifier
    assert_tag :a, :attributes => {:class => 'button icon-menu-ctrl-panel'}
  end


  # USER NOT LOGGED IN

  should 'not display *send email to administrators* button when the user is not logged in' do
    logout
    get :index, :profile => @community.identifier
    assert_no_tag :a, :attributes => {:class => 'button icon-menu-mail'}
  end

  should 'not display *report* button when the user is not logged in' do
    logout
    get :index, :profile => @community.identifier
    assert_no_tag :a, :attributes => {:class => 'button icon-alert report-abuse-action'}
  end

  should 'not display *configure* button when the user is logged in and is admin of the community' do
    logout
    get :index, :profile => @community.identifier
    assert_no_tag :a, :attributes => {:class => 'button icon-menu-ctrl-panel link-this-page'}
  end

end
