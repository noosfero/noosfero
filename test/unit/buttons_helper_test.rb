require_relative "../test_helper"

class ButtonsHelperTest < ActionView::TestCase

  include ButtonsHelper

  should 'append with-text class and keep existing classes' do
    expects(:button_without_text).with('type', 'label', 'url', { :class => 'with-text class1'})
    button('type', 'label', 'url', { :class => 'class1' })
  end

  should 'envelop a html with button-bar div' do
    result = button_bar { content_tag :b, 'foo' }
    assert_equal '<div class=" button-bar"><b>foo</b>'+
                 '<br style="clear: left;" /></div>', result
  end

  should 'add more classes to button-bar envelope' do
    result = button_bar :class=>'test' do
      content_tag :b, 'foo'
    end
    assert_equal '<div class="test button-bar"><b>foo</b>'+
                 '<br style="clear: left;" /></div>', result
  end

  should 'add more attributes to button-bar envelope' do
    result = button_bar :id=>'bt1' do
      content_tag :b, 'foo'
    end
    assert_tag_in_string result, :tag =>'div', :attributes => {:class => ' button-bar', :id => 'bt1'}
    assert_tag_in_string result, :tag =>'b', :content => 'foo', :parent => {:tag => 'div', :attributes => {:id => 'bt1'}}
    assert_tag_in_string result, :tag =>'br', :parent => {:tag => 'div', :attributes => {:id => 'bt1'}}
  end

end
