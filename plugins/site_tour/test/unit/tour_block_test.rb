require 'test_helper'

class TrackListBlockTest < ActionView::TestCase

  ActionView::Base.send :include, ApplicationHelper

  def setup
    @block = fast_create(SiteTourPlugin::TourBlock)
  end

  attr_accessor :block

  should 'do not save empty actions' do
    block.actions = [{:group_name => '', :selector => nil, :description => ' '}]
    block.save!
    assert_equal [], block.actions
  end

  should 'render script tag in visualization mode' do
    controller.expects(:boxes_editor?).returns(false)
    assert_tag_in_string instance_eval(&block.content), :tag => 'script'
  end

  should 'do not render script tag when editing' do
    controller.expects(:boxes_editor?).returns(true)
    controller.expects(:uses_design_blocks?).returns(true)
    assert_no_tag_in_string instance_eval(&block.content), :tag => 'script'
  end

  should 'display help button' do
    controller.expects(:boxes_editor?).returns(false)
    assert_tag_in_string instance_eval(&block.content), :tag => 'a', :attributes => {:class => 'button icon-help with-text tour-button'}
  end

  should 'do not display help button when display_button is false' do
    block.display_button = false
    controller.expects(:boxes_editor?).returns(false)
    assert_no_tag_in_string instance_eval(&block.content), :tag => 'a', :attributes => {:class => 'button icon-help with-text tour-button'}
  end

end
