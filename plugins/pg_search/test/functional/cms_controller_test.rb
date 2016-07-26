require "test_helper"

class CmsControllerTest < ActionController::TestCase

  should 'list communities available to spread' do
    env = Environment.default
    env.enable_plugin(PgSearchPlugin)
    profile = create_user('profile').person
    login_as(profile.identifier)

    c1 = fast_create(Community, :name => 'Testing community 1', :identifier => 'testcommunity1', :environment_id => env)
    c1.add_member profile
    c2 = fast_create(Community, :name => 'Testing community 2', :identifier => 'testcommunity2', :environment_id => env)
    c2.add_member profile
    c2.add_admin profile

    assert_nothing_raised do
      get :search_communities_to_publish, :profile => profile.identifier, :q => 'Testing'
    end

    assert_match /Testing community 1/, @response.body
    assert_match /Testing community 2/, @response.body
  end

  should 'not duplicated a community in list of communities available to spread' do
    env = Environment.default
    env.enable_plugin(PgSearchPlugin)
    profile = create_user('profile').person
    login_as(profile.identifier)

    c1 = fast_create(Community, :name => 'Testing community 1', :identifier => 'testcommunity1', :environment_id => env)
    c1.add_member profile
    c2 = fast_create(Community, :name => 'Testing community 2', :identifier => 'testcommunity2', :environment_id => env)
    c2.add_member profile
    c2.add_admin profile

    get :search_communities_to_publish, :profile => profile.identifier, :q => 'Testing'
    assert_equivalent [c1.id, c2.id],  JSON.parse(@response.body).map{|c|c['id']}
  end

end
