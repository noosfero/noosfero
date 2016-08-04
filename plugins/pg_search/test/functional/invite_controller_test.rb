require "test_helper"

class InviteControllerTest < ActionController::TestCase

  should 'list people available to invite' do
    env = Environment.default
    env.enable_plugin(PgSearchPlugin)
    profile = create_user('profile').person
    login_as(profile.identifier)

    community = fast_create(Community, :name => 'Testing community 1', :identifier => 'testcommunity1', :environment_id => env)
    community.add_admin profile

    p1 = fast_create(Person, :identifier => 'someone')
    p2 = fast_create(Person, :identifier => 'someother')

    assert_nothing_raised do
      get :search, :profile => community.identifier, :q => 'some'
    end
  end

end
