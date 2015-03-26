require "test_helper"

class SearchControllerTest < ActionController::TestCase

  def setup
    environment = Environment.default
    environment.enable_plugin(PgSearchPlugin)
  end

  should 'list all communities' do
    plugin = PgSearchPlugin.new
    c1 = fast_create(Community, :name => 'Testing community 1')
    c2 = fast_create(Community, :name => 'Testing community 3')
    c3 = fast_create(Community, :name => 'Testing community 3')

    get :communities
    assert_equivalent [c1, c2, c3], assigns(:searches)[:communities][:results]
  end

  should 'list communities of a specific template' do
    plugin = PgSearchPlugin.new
    t1 = fast_create(Community, :is_template => true)
    t2 = fast_create(Community, :is_template => true)
    c1 = fast_create(Community, :template_id => t1.id, :name => 'Testing community 1')
    c2 = fast_create(Community, :template_id => t2.id, :name => 'Testing community 2')
    c3 = fast_create(Community, :template_id => t1.id, :name => 'Testing community 3')
    c4 = fast_create(Community, :name => 'Testing community 3')

    get :communities, :template_id => t1.id
    assert_equivalent [c1, c3], assigns(:searches)[:communities][:results]
  end
end
