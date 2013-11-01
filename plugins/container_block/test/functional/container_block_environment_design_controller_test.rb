require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class EnvironmentDesignController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  def rescue_action(e) 
    raise e 
  end 
end

class EnvironmentDesignControllerTest < ActionController::TestCase

  def setup
    Environment.delete_all
    @environment = Environment.new(:name => 'testenv', :is_default => true)
    @environment.enabled_plugins = ['ContainerBlock']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    @block = ContainerBlock.create!(:box => @environment.boxes.first)
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

  should 'display container children' do
    c1 = RawHTMLBlock.create!(:box => @block.container_box, :html => 'child1 content')
    get :index
    assert_tag :div, :attributes => { :id => "block-#{c1.id}" }
  end

  should 'display hidden children of container block' do
    c1 = RawHTMLBlock.create!(:box => @block.container_box, :html => 'child1 content', :display => 'never')
    get :index
    assert_tag :div, :attributes => { :id => "block-#{c1.id}", :class => 'block raw-html-block invisible-block' }
  end

  should 'display button to save widths of container children' do
    c1 = RawHTMLBlock.create!(:box => @block.container_box, :html => 'child1 content')
    get :index
    assert_tag :a, :attributes => { :class => "button icon-save container_block_save" }
  end

end
