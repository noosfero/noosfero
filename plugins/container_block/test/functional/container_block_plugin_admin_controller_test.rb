require 'test_helper'

class ContainerBlockPluginAdminControllerTest < ActionController::TestCase

  def setup
    Environment.delete_all
    @environment = Environment.new(:name => 'testenv', :is_default => true)
    @environment.enabled_plugins = ['ContainerBlockPlugin::ContainerBlock']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    @block = ContainerBlockPlugin::ContainerBlock.create!(:box_id => @environment.boxes.first.id)
    @child1 = Block.create!(:box_id => @block.container_box.id)
    @child2 = Block.create!(:box_id => @block.container_box.id)
  end

  should 'save widths of container block children' do
    xhr :post, :saveWidths, :id => @block.id, :widths => "#{@child1.id},100|#{@child2.id},200"
    assert_response 200
    assert_equal 'Block successfully saved.', @response.body
    @block.reload
    assert_equal 100, @block.child_width(@child1.id)
    assert_equal 200, @block.child_width(@child2.id)
  end

end
