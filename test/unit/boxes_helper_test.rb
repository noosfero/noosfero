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

end
