require_relative '../test_helper'

class ProfileDesignControllerTest < ActionController::TestCase

  def setup
    @controller = ProfileDesignController.new

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([PeopleBlockPlugin.new])
  end

  should 'display *block people-block* class at design blocks page' do
    user = create_user('testinguser')
    login_as(user.login)

    @profile = user.person
    @environment = @profile.environment
    @environment.save!

    FriendsBlock.delete_all
    @box1 = Box.create!(:owner => @profile)
    @profile.boxes = [@box1]

    @block = FriendsBlock.new
    @block.box = @box1
    @block.save!

    @profile.blocks<<@block
    @profile.save!

    get :index, :profile => @profile.identifier
    assert_tag :div, :attributes => {:class => 'block friends-block'}
  end

  should 'the people block is available for person profile' do
    profile = Person.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    assert_includes @controller.available_blocks, FriendsBlock
  end

  should 'the people block is available for community profile' do
    profile = Community.new
    profile.stubs(:has_blog?).returns(false)
    profile.stubs(:is_admin?).with(anything).returns(false)
    environment = mock
    profile.stubs(:environment).returns(environment)
    environment.stubs(:enabled?).returns(false)
    @controller.stubs(:profile).returns(profile)
    @controller.stubs(:user).returns(profile)
    assert_includes @controller.available_blocks, MembersBlock
  end

end
