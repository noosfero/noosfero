require File.dirname(__FILE__) + '/../test_helper'
require 'templates_controller'

# Re-raise errors caught by the controller.
class TemplatesController; def rescue_action(e) raise e end; end

class TemplatesControllerTest < ActionController::TestCase

  def setup
    @controller = TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Environment.destroy_all
    @environment = fast_create(Environment, :is_default => true)
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

end

