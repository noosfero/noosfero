require "test_helper"

class CmsControllerTest < ActionController::TestCase

  def setup
    @env = Environment.default
    @env.enable_plugin(SubOrganizationsPlugin)

    @profile = create_user('profile').person
    login_as(@profile.identifier)
  end

  should 'list and not duplicate sub organizations when spreading an article' do
    c1 = fast_create(Community, :name => 'Testing community 1', :identifier => 'testcommunity1', :environment_id => @env)
    c2 = fast_create(Community, :name => 'Testing community 2', :identifier => 'testcommunity2', :environment_id => @env)
    SubOrganizationsPlugin::Relation.add_children(c1, c2)
    c2.add_member @profile
    c2.add_admin @profile

    get :search_communities_to_publish, :profile => @profile.identifier, :q => 'Testing'
    assert_equivalent [c1.id, c2.id],  JSON.parse(@response.body).map{|c|c['id']}
  end

end
