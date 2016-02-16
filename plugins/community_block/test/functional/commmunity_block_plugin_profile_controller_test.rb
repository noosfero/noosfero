require_relative '../test_helper'

class ProfileControllerTest < ActionController::TestCase

  def setup
    @user = create_user('testinguser').person
    login_as(@user.identifier)

    @community = fast_create(Community, :environment_id => Environment.default)
    @community.add_member @user
    @community.add_admin @user

    @environment = @community.environment
    @environment.enabled_plugins = ['CommunityBlock']
    @environment.save!

    CommunityBlock.delete_all
    @box1 = create(Box, :owner => @community)
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
    assert_tag :div, :attributes => {:class => 'community-block-title'}
    assert_tag :div, :attributes => {:class => 'community-block-description'}
  end

  should 'display *leave* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_tag :span, :attributes => {:class => 'community-block-button icon-remove'}
  end

  should 'display *send email to administrators* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_match /\{&quot;Send an e-mail&quot;:\{&quot;href&quot;:&quot;\/contact\/#{@community.identifier}\/new&quot;\}\}/, @response.body
  end

  should 'display *report* button when the user is logged in and is a member of the community' do
    get :index, :profile => @community.identifier
    assert_match /\{&quot;Report abuse&quot;:\{&quot;href&quot;:&quot;\/profile\/#{@community.identifier}\/report_abuse&quot;\}\}/, @response.body
  end

  should 'display *join* button when the user is logged in and is not a member of the community' do
    @community.remove_member @user
    get :index, :profile => @community.identifier
    assert_tag :span, :attributes => {:class => 'community-block-button icon-add'}
  end

  should 'display *control panel* link option when the user is logged in and is community admin' do
    get :index, :profile => @community.identifier
    assert_match /\{&quot;Control panel&quot;:\{&quot;href&quot;:&quot;\/myprofile\/#{@community.identifier}&quot;\}\}/, @response.body
  end

  should 'display *join* button when the user is not logged in' do
    logout
    get :index, :profile => @community.identifier
    assert_tag :span, :attributes => {:class => 'community-block-button icon-add'}
  end

  should 'not display *arrow* button when the user is not logged in' do
    logout
    get :index, :profile => @community.identifier
    assert_no_tag :span, :attributes => {:class => 'community-block-button icon-arrow'}
  end

end
