require File.dirname(__FILE__) + '/../test_helper'
require 'environment_design_controller'

# Re-raise errors caught by the controller.
class EnvironmentDesignController; def rescue_action(e) raise e end; end

class EnvironmentDesignControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnvironmentDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'indicate only actual blocks as such' do
    assert(@controller.available_blocks.all? {|item| item.new.is_a? Block})
  end

  should 'LinkListBlock is available' do
    assert_includes @controller.available_blocks, LinkListBlock
  end

  should 'be able to edit LinkListBlock' do
    login_as(create_admin_user(Environment.default))
    l = LinkListBlock.create!(:links => [{:name => 'link 1', :address => '/address_1'}])
    Environment.default.boxes.create!
    Environment.default.boxes.first.blocks << l
    get :edit, :id => l.id
    assert_tag :tag => 'input', :attributes => { :name => 'block[links][][name]' }
    assert_tag :tag => 'input', :attributes => { :name => 'block[links][][address]' }
  end

  should 'be able to save LinkListBlock' do
    login_as(create_admin_user(Environment.default))
    l = LinkListBlock.create!()
    Environment.default.boxes.create!
    Environment.default.boxes.first.blocks << l
    post :save, :id => l.id, :block => { :links => [{:name => 'link 1', :address => '/address_1'}] }
    l.reload
    assert_equal [{'name' => 'link 1', 'address' => '/address_1'}], l.links
  end
  
end
