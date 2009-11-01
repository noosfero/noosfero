require File.dirname(__FILE__) + '/../test_helper'

class BoxesHelperTest < Test::Unit::TestCase

  include BoxesHelper
  include ActionView::Helpers::TagHelper

  should 'include profile-specific header' do
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_header_expanded).returns('my custom header')

    assert_tag_in_string display_boxes(holder, 'main content'), :tag => "div", :attributes => { :id => 'profile-header' }, :content => 'my custom header'
  end

  should 'include profile-specific footer' do
    holder = mock
    holder.stubs(:boxes).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_footer_expanded).returns('my custom footer')

    assert_tag_in_string display_boxes(holder, 'main content'), :tag => "div", :attributes => { :id => 'profile-footer' }, :content => 'my custom footer'
  end

  def create_user_with_blocks
    p = create_user('test_user').person
    LinkListBlock.create!(:box => p.boxes.first)
    p
  end

  should 'display invisible block for editing' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.visible = false; b.save!
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
    b.visible = false; b.save!
    box = b.box
    box.expects(:blocks).returns([b])
    expects(:display_block).with(b, '').never
    stubs(:block_target).returns('')
    display_box_content(box, '')
  end

end
