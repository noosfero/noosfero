require File.dirname(__FILE__) + '/../test_helper'

class BoxesHelperTest < Test::Unit::TestCase

  include BoxesHelper
  include ActionView::Helpers::TagHelper

  def setup
    @controller = mock
    @controller.stubs(:boxes_editor?).returns(false)
    @controller.stubs(:uses_design_blocks?).returns(true)
  end

  should 'include profile-specific header' do
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_header_expanded).returns('my custom header')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-header' }, :content => 'my custom header'
  end

  should 'include profile-specific footer' do
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_footer_expanded).returns('my custom footer')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-footer' }, :content => 'my custom footer'
  end

  def create_user_with_blocks
    p = create_user('test_user').person
    LinkListBlock.create!(:box => p.boxes.first)
    p
  end

  should 'display invisible block for editing' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.display = 'never'; b.save!
    box = b.box
    box.expects(:blocks).returns([b])
    expects(:display_block).with(b, '')
    stubs(:block_target).returns('')
    with_box_decorator self do
      display_box_content(box, '')
    end
  end

  should 'not display invisible block' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.display = 'never'; b.save!
    box = b.box
    box.expects(:blocks).returns([b])
    expects(:display_block).with(b, '').never
    stubs(:block_target).returns('')
    display_box_content(box, '')
  end

  should 'include profile-specific header without side boxes' do
    @controller.stubs(:uses_design_blocks?).returns(false)
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_header_expanded).returns('my custom header')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-header' }, :content => 'my custom header'
  end

  should 'include profile-specific footer without side boxes' do
    @controller.stubs(:uses_design_blocks?).returns(false)
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_footer_expanded).returns('my custom footer')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-footer' }, :content => 'my custom footer'
  end

  should 'calculate CSS class names correctly' do
    assert_equal 'slideshow-block', block_css_class_name(SlideshowBlock.new)
    assert_equal 'main-block', block_css_class_name(MainBlock.new)
  end

  should 'add invisible CSS class name for invisible blocks' do
    assert !block_css_classes(Block.new(:display => 'always')).split.any? { |item| item == 'invisible-block'}
    assert block_css_classes(Block.new(:display => 'never')).split.any? { |item| item == 'invisible-block'}
  end
end
