require_relative '../../../../test/test_helper'
require_relative '../../lib/pg_search_plugin'

class InviteControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(PgSearchPlugin)
  end

  attr_accessor :environment

  should 'list people available to invite' do
    profile = create_user('profile').person
    login_as(profile.identifier)

    community = fast_create(Community, :name => 'Testing community 1', :identifier => 'testcommunity1', :environment_id => environment)
    community.add_admin profile

    p1 = fast_create(Person, :identifier => 'someone')
    p2 = fast_create(Person, :identifier => 'someother')

    assert_nothing_raised do
      get :search, :profile => community.identifier, :q => 'some'
    end
  end

end
