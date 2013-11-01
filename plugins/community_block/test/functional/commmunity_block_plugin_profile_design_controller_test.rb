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

    #user = create_user('testinguser')
    #login_as(user.login)

    @community = fast_create(Community, :environment_id => Environment.default)

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

  attr_accessor :profile, :block, :community

  should 'display community-block-logo class in community block' do
    get :index, :profile => community.identifier
    assert_tag :div, :attributes => {:class => 'community-block-logo'}
  end

  should 'display community-block-info class in community block' do
    get :index, :profile => community.identifier
    assert_tag :div, :attributes => {:class => 'community-block-info'}
  end

  should 'display community-block-title class in community block' do
    get :index, :profile => community.identifier
    assert_tag :h1, :attributes => {:class => 'community-block-title'}
  end

  should 'display community-block-description class in community block' do
    get :index, :profile => community.identifier
    assert_tag :div, :attributes => {:class => 'community-block-description'}
  end

  should 'display community-block-buttons class in community block' do
    get :index, :profile => community.identifier
    assert_tag :div, :attributes => {:class => 'community-block-buttons'}
  end

end
