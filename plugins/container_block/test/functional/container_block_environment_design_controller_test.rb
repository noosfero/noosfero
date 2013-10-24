require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class EnvironmentDesignController; def rescue_action(e) raise e end; end

class EnvironmentDesignControllerTest < ActionController::TestCase

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
  end

  should 'be able to edit ContainerBlock' do
    get :edit, :id => @block.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save ContainerBlock' do
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:title => 'Container' }
    @block.reload
    assert_equal 'Container', @block.title
  end

end
