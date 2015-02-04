require File.dirname(__FILE__) + '/../../../../test/test_helper'

# Re-raise errors caught by the controller.
class HomeController
  def rescue_action(e)
    raise e
  end
end

class ProfileControllerTest < ActionController::TestCase
  def setup
    @env = Environment.default
    @env.enable_plugin('ClassifyMembersPlugin')

    @p1  = fast_create(Person, :environment_id => @env.id)
    @p2  = fast_create(Person, :environment_id => @env.id)
    @c1  = fast_create(Community, :environment_id => @env.id)
    @c2  = fast_create(Community, :environment_id => @env.id)

    # Register cassification communities:
    ClassifyMembersPlugin.new(self).settings.communities = "#{@c1.identifier}: Test-Tag"
    @env.save!

    @c1.add_member @p1
    @c2.add_member @p1
    @c2.add_member @p2
  end

  def environment
    @env
  end

  should 'add classification to the <html>' do
    get :index, :profile => @p1.identifier

    assert_select 'html.member-of-' + @c1.identifier
    assert_select 'html.member-of-' + @c2.identifier, false
  end

  should 'not add classification to a non member' do
    get :index, :profile=>@p2.identifier

    assert_select 'html.member-of-' + @c1.identifier, false
  end
end
