require_relative '../test_helper'

class ProfileControllerTest < ActionController::TestCase

  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([PeopleBlockPlugin.new])
  end

  should 'show suggestions to logged in owner' do
    user = create_user('testinguser')
    login_as(user.login)
    owner = user.person

    suggestion1 = ProfileSuggestion.create!(:suggestion => fast_create(Person), :person => owner)
    suggestion2 = ProfileSuggestion.create!(:suggestion => fast_create(Person), :person => owner)

    FriendsBlock.delete_all
    block = FriendsBlock.new
    block.box = owner.boxes.first
    block.save!

    get :index, :profile => owner.identifier
    assert_response :success
    assert_tag :div, :attributes => {:class => 'profiles-suggestions'}
    assert_template :partial => 'shared/_profile_suggestions_list', :locals => { :suggestions => block.suggestions }
    assert_tag :a, :content => 'See all suggestions'
  end

end
