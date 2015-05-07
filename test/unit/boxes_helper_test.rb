require_relative "../test_helper"
require 'boxes_helper'

class BoxesHelperTest < ActionView::TestCase

  include ApplicationHelper
  include BoxesHelper
  include ActionView::Helpers::TagHelper

  def setup
    @controller = mock
    @controller.stubs(:custom_design).returns({})
    @controller.stubs(:boxes_editor?).returns(false)
    @controller.stubs(:uses_design_blocks?).returns(true)
  end

  should 'include profile-specific header' do
    holder = mock
    holder.stubs(:boxes).returns(boxes = [])
    boxes.stubs(:with_position).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_header_expanded).returns('my custom header')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-header' }, :content => 'my custom header'
  end

  should 'include profile-specific footer' do
    holder = mock
    holder.stubs(:boxes).returns(boxes = [])
    boxes.stubs(:with_position).returns([])
    holder.stubs(:boxes_limit).returns(0)
    holder.stubs(:custom_footer_expanded).returns('my custom footer')
    @controller.stubs(:boxes_holder).returns(holder)

    assert_tag_in_string insert_boxes('main content'), :tag => "div", :attributes => { :id => 'profile-footer' }, :content => 'my custom footer'
  end

  def create_user_with_blocks
    p = create_user('test_user').person
    create(LinkListBlock, :box => p.boxes.first)
    p
  end

  should 'display invisible block for editing' do
    p = create_user_with_blocks
    request = mock()
    request.expects(:path).returns(nil)
    request.expects(:params).returns({})


    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.display = 'never'; b.save!
    box = b.box
    box.blocks = [b]
    box.save!
    expects(:display_block).with(b, '')
    stubs(:request).returns(request)
    stubs(:block_target).returns('')
    stubs(:user).returns(nil)
    expects(:locale).returns('en')
    with_box_decorator self do
      display_box_content(box, '')
    end
  end

  should 'not display invisible block' do
    p = create_user_with_blocks
    request = mock()
    request.expects(:path).returns(nil)
    request.expects(:params).returns({})

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.display = 'never'; b.save!
    box = b.box
    box.blocks = [b]
    box.save!
    expects(:display_block).with(b, '').never
    stubs(:request).returns(request)
    stubs(:user).returns(nil)
    stubs(:block_target).returns('')
    expects(:locale).returns('en')
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

  should 'add invisible CSS class name for invisible blocks' do
    assert !block_css_classes(build(Block, :display => 'always')).split.any? { |item| item == 'invisible-block'}
    assert block_css_classes(build(Block, :display => 'never')).split.any? { |item| item == 'invisible-block'}
  end

  should 'fill context with the article, request_path and locale' do
    request = mock()
    box = create(Box, :owner => fast_create(Profile))
    request.expects(:path).returns('/')
    request.expects(:params).returns({})
    stubs(:request).returns(request)
    stubs(:user).returns(nil)
    expects(:locale).returns('en')
    box_decorator.expects(:select_blocks).with(box, [], {:article => nil, :request_path => '/', :locale => 'en', :params => {}, :user => nil, :controller => @controller}).returns([])

    display_box_content(box, '')
  end

  should 'not show move options on block when block has no permission to edit' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.move_modes = "none"
    b.save!

    stubs(:environment).returns(p.environment)
    stubs(:user).returns(p)

    assert_equal false, movable?(b)
  end

  should 'show move options on block when block has no permission to edit and user is admin' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.edit_modes = "none"
    b.save!

    p.environment.add_admin(p)

    stubs(:environment).returns(p.environment)
    stubs(:user).returns(p)

    assert_equal true, movable?(b)
  end

  should 'consider boxes_limit without custom_design' do
    holder = mock
    holder.stubs(:boxes_limit).with(nil).returns(2)
    assert_equal 2, boxes_limit(holder)
  end

  should 'consider boxes_limit with custom_design' do
    holder = mock
    @controller.expects(:custom_design).returns({boxes_limit: 1})

    assert_equal 1, boxes_limit(holder)
  end

  should 'insert block using custom_design' do
    request = mock
    request.expects(:path).returns('/')
    request.expects(:params).returns({})
    stubs(:request).returns(request)
    stubs(:user).returns(nil)
    expects(:locale).returns('en')

    box = create(Box, position: 1, owner: fast_create(Profile))
    block = ProfileImageBlock
    block.expects(:new).with(box: box)

    @controller.expects(:custom_design).returns({insert: {position: 1, block: block, box: 1}})

    stubs(:display_block)
    display_box_content(box, '')
  end

  should 'display embed button when a block is embedable' do
    box = create(Box, position: 1, owner: fast_create(Profile))
    block = Block.create!(:box => box)
    block.stubs(:embedable?).returns(true)
    stubs(:url_for).returns('')
    assert_tag_in_string block_edit_buttons(block), :tag => 'a', :attributes => {:class => 'button icon-button icon-embed '}
  end

  should 'not display embed button when a block is not embedable' do
    box = create(Box, position: 1, owner: fast_create(Profile))
    block = Block.create!(:box => box)
    block.stubs(:embedable?).returns(false)
    stubs(:url_for).returns('')
    assert_no_tag_in_string block_edit_buttons(block), :tag => 'a', :attributes => {:class => 'button icon-button icon-embed '}
  end

  should 'only show edit option on block' do
    p = create_user_with_blocks

    b = p.blocks.select{|bk| !bk.kind_of?(MainBlock) }[0]
    b.edit_modes = "only_edit"
    b.save!

    stubs(:environment).returns(p.environment)
    stubs(:user).returns(p)

    assert_equal false, b.editable?
  end
end
