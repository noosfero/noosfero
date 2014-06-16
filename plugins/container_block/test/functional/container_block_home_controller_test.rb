require 'test_helper'

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
    @environment.enabled_plugins = ['ContainerBlockPlugin::ContainerBlock']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    box = create(Box, :owner => @environment)
    @block = create(ContainerBlockPlugin::ContainerBlock, :box => box)
    
    @environment.boxes = [box]
  end

  should 'display ContainerBlock' do
    get :index
    assert_tag :div, :attributes => { :class => 'block container-block-plugin_container-block' }
  end

  should 'display block title' do
    @block.title = "Block Title"
    @block.save!
    get :index
    assert_tag :div, :attributes => { :class => 'block container-block-plugin_container-block' }, :descendant => {:tag => 'h3', :attributes => { :class => "block-title"}, :content => @block.title }
  end

  should 'display container children' do
    c1 = RawHTMLBlock.create!(:box_id => @block.container_box.id, :html => 'child1 content')
    c2 = RawHTMLBlock.create!(:box_id => @block.container_box.id, :html => 'child2 content')
    get :index
    assert_tag :div, :attributes => { :id => "block-#{c1.id}" }
    assert_tag :div, :attributes => { :id => "block-#{c2.id}" }
  end

  should 'display style tags for container children' do
    c1 = RawHTMLBlock.create!(:box_id => @block.container_box.id, :html => 'child1 content')
    @block.children_settings = { c1.id => {:width => "123"} }
    @block.save!
    get :index
    assert_match /#block-#{c1.id} \{ width: 123px; \}/, @response.body
  end

  should 'do not display hidden children of container' do
    c1 = RawHTMLBlock.create!(:box_id => @block.container_box.id, :html => 'child1 content', :display => 'never')
    get :index
    assert_no_tag :div, :attributes => { :id => "block-#{c1.id}" }
  end

  should 'do not display button to save widths of container children' do
    get :index
    assert_no_tag :a, :attributes => { :class => "button icon-save container_block_save" }
  end

end
