require 'test_helper'

class ContainerBlockPluginControllerTest < ActionController::TestCase

  include ContainerBlockPluginController

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
    @environment = Environment.find(@environment.id)
    stubs(:boxes_holder).returns(@environment)
    @params = {}
  end

  attr_reader :params

  should 'save widths of container block children' do
    @params = {:id => @block.id, :widths => "#{@child1.id},100|#{@child2.id},200"}
    expects(:render).with(:text => 'Block successfully saved.')
    saveWidths
    @block.reload
    assert_equal 100, @block.child_width(@child1.id)
    assert_equal 200, @block.child_width(@child2.id)
  end

  should 'do not change child width that is not passed in widths param' do
    @block.children_settings = {@child2.id => {:width => 200}}
    @block.save!
    @params = {:id => @block.id, :widths => "#{@child1.id},100"}
    expects(:render).with(:text => 'Block successfully saved.')
    saveWidths
    @block.reload
    assert_equal 100, @block.child_width(@child1.id)
    assert_equal 200, @block.child_width(@child2.id)
  end

end
