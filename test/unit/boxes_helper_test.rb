require File.dirname(__FILE__) + '/../test_helper'

class BoxesHelperTest < ActiveSupport::TestCase

  include BoxesHelper
  include ActionView::Helpers::TagHelper

  def setup
    @controller = mock
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
    LinkListBlock.create!(:box => p.boxes.first)
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
    assert !block_css_classes(Block.new(:display => 'always')).split.any? { |item| item == 'invisible-block'}
    assert block_css_classes(Block.new(:display => 'never')).split.any? { |item| item == 'invisible-block'}
  end

  should 'fill context with the article, request_path, user and locale' do
    request = mock()
    box = Box.create!(:owner => fast_create(Profile))
    request.expects(:path).returns('/')
    request.expects(:params).returns({})
    stubs(:request).returns(request)
    stubs(:user).returns(nil)
    expects(:locale).returns('en')
    box_decorator.expects(:select_blocks).with([], {:article => nil, :request_path => '/', :locale => 'en', :params => {}, :user => nil}).returns([])

    display_box_content(box, '')
  end

  should 'filter blocks by user' do
    b1 = Block.new
    b2 = Block.new
    arr = user_filter([b1, b2], {:display_user => 'all'})
    assert_equivalent [b1, b2], arr
  end

  should 'filter blocks by logged user' do
    b1 = Block.new(:display_user => 'logged')
    b2 = Block.new(:display_user => 'not_logged')
    stubs(:user).returns(User.new)
    arr = user_filter([b1, b2], {:display_user => 'logged'})
    assert_equivalent [b1], arr
  end

  should 'filter blocks by not logged user' do
    b1 = Block.new(:display_user => 'logged')
    b2 = Block.new(:display_user => 'not_logged')
    stubs(:user).returns(User.new)
    arr = user_filter([b1, b2], {:display_user => 'not_logged'})
    assert_equivalent [b2], arr
  end

  should 'select blocks by user filter' do
    b = Block.new
    expects(:user_filter).once.returns([b])
    arr = select_blocks([], {:psarams => {}})
    assert_equal [b], arr
  end

end
