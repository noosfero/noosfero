require_relative "../test_helper"
require 'templates_controller'

class TemplatesControllerTest < ActionController::TestCase

  def setup
    @controller = TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    login_as(create_admin_user(@environment))
  end
  attr_accessor :environment

  should 'create person template' do
    post :create_person_template, :name => 'Developer'
    assert Person['developer'].is_template
  end

  should 'create community template' do
    post :create_community_template, :name => 'Debian'
    assert Community['debian'].is_template
  end

  should 'create enterprise template' do
    post :create_enterprise_template, :name => 'Free Software Foundation'
    assert Enterprise['free-software-foundation'].is_template
  end

  should 'set a community as default template' do

    c1= fast_create(Community, :is_template => true, :environment_id => environment.id)
    environment.community_default_template= c1
    environment.save

    c3 = fast_create(Community, :is_template => true, :environment_id => environment.id)

    post :set_community_as_default, :template_id => c3.id
    environment.reload
    assert_equal c3, environment.community_default_template
  end

  should 'set a person as default template' do

    p1= fast_create(Person, :is_template => true, :environment_id => environment.id)
    environment.person_default_template= p1
    environment.save

    p3 = fast_create(Person, :is_template => true, :environment_id => environment.id)

    post :set_person_as_default, :template_id => p3.id
    environment.reload
    assert_equal p3, environment.person_default_template
  end

  should 'set a enterprise as default template' do

    e1= fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    environment.enterprise_default_template= e1
    environment.save

    e3 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)

    post :set_enterprise_as_default, :template_id => e3.id
    environment.reload
    assert_equal e3, environment.enterprise_default_template
  end

  should 'not allow set_community_as_default define a community template of another environment as default' do
    c1= fast_create(Community, :is_template => true, :environment_id => environment.id)
    environment.community_default_template= c1
    environment.save

    env2 = fast_create(Environment)

    c3 = fast_create(Community, :is_template => true, :environment_id => env2.id)

    post :set_community_as_default, :template_id => c3.id
    environment.reload
    assert_not_equal c3, environment.community_default_template
  end

  should 'not allow set_person_as_default define a person template of another environment as default' do
    p1= fast_create(Person, :is_template => true, :environment_id => environment.id)
    environment.person_default_template= p1
    environment.save

    env2 = fast_create(Environment)
    p3 = fast_create(Person, :is_template => true, :environment_id => env2.id)

    post :set_person_as_default, :template_id => p3.id
    environment.reload
    assert_not_equal p3, environment.person_default_template

  end

  should 'not allow set_enterprise_as_default define a enterprise of another environment as default' do
    e1= fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    environment.enterprise_default_template= e1
    environment.save

    env2 = fast_create(Environment)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env2.id)

    post :set_enterprise_as_default, :template_id => e3.id
    environment.reload
    assert_not_equal e3, environment.enterprise_default_template
  end

  should 'display successfully notice message after define a community template as default' do
    c3 = fast_create(Community, :is_template => true, :environment_id => environment)

    post :set_community_as_default, :template_id => c3.id
    assert_equal "#{c3.name} defined as default", session[:notice]
  end

  should 'display successfully notice message after define a person template as default' do
    p3 = fast_create(Person, :is_template => true, :environment_id => environment)

    post :set_person_as_default, :template_id => p3.id
    assert_equal "#{p3.name} defined as default", session[:notice]
  end

  should 'display successfully notice message after define a enterprise template as default' do
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => environment)

    post :set_enterprise_as_default, :template_id => e3.id
    assert_equal "#{e3.name} defined as default", session[:notice]
  end

  should 'display unsuccessfully notice message when a community template could not be defined as default' do
    env2 = fast_create(Environment)
    c3 = fast_create(Community, :is_template => true, :environment_id => env2.id)

    post :set_community_as_default, :template_id => c3.id
    assert_equal "Community not found. The template could no be changed.", session[:notice]
  end

  should 'display unsuccessfully notice message when a person template could not be defined as default' do
    env2 = fast_create(Environment)
    p3 = fast_create(Person, :is_template => true, :environment_id => env2.id)

    post :set_person_as_default, :template_id => p3.id
    assert_equal "Person not found. The template could no be changed.", session[:notice]
  end

  should 'display unsuccessfully notice message when a enterprise template could not be defined as default' do
    env2 = fast_create(Environment)
    e3 = fast_create(Community, :is_template => true, :environment_id => env2.id)

    post :set_enterprise_as_default, :template_id => e3.id
    assert_equal "Enterprise not found. The template could no be changed.", session[:notice]
  end

  should 'display set as default link for non default community templates' do
    c1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    c2 = fast_create(Community, :is_template => true, :environment_id => environment.id)

    get :index
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_community_as_default?template_id=#{c1.id}"}
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_community_as_default?template_id=#{c2.id}"}
  end

  should 'display set as default link for non default person templates' do
    p1 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    p2 = fast_create(Person, :is_template => true, :environment_id => environment.id)

    get :index
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_person_as_default?template_id=#{p1.id}"}
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_person_as_default?template_id=#{p2.id}"}
  end

  should 'display set as default link for non default enterprise templates' do
    e1 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    e2 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)

    get :index
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_enterprise_as_default?template_id=#{e1.id}"}
    assert_tag :a, '', :attributes => {:href => "/admin/templates/set_enterprise_as_default?template_id=#{e2.id}"}
  end

  should 'not display set as default link for default community template' do
    c1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    c2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    environment.community_default_template= c1
    environment.save

    get :index
    assert_no_tag :a, '', :attributes => {:href => "/admin/templates/set_community_as_default?template_id=#{c1.id}"}
  end

end

