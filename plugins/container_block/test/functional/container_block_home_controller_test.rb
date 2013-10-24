require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class HomeController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  def rescue_action(e) 
    raise e 
  end 
end

class HomeControllerTest < ActionController::TestCase

  def setup
    Environment.delete_all
    @environment = Environment.new(:name => 'testenv', :is_default => true)
    @environment.enabled_plugins = ['ContainerBlock']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    box = Box.create!(:owner => @environment)
    @block = ContainerBlock.create!(:box => box)
    
    @environment.boxes = [box]
  end

  should 'display ContainerBlock' do
    get :index
    assert_tag :div, :attributes => { :class => 'block container-block' }
  end

end
