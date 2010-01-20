require File.dirname(__FILE__) + '/../test_helper'

class ThickboxHelperTest < Test::Unit::TestCase
  include ThickboxHelper

  def url_for(url)
    url
  end

  should 'create thickbox links correcly' do
    expects(:link_to).with('Title', '/url#TB_inline?height=300&width=500&inlineId=inlineLoginBox&modal=true', :class => 'thickbox')
    thickbox_inline_popup_link('Title', '/url', 'inlineLoginBox')
  end

  should 'pass along extra options' do
    expects(:link_to).with('Title', anything, :class => 'thickbox', :id => 'lalala', :title => 'lelele')
    thickbox_inline_popup_link('Title', '/url', 'inlineLoginBox', :id => 'lalala', :title => 'lelele')
  end

  should 'generate close button' do
    expects(:button_to_function).with(:close, 'Title', 'tb_remove();').returns('[close-button]')
    assert_equal '[close-button]', thickbox_close_button('Title')
  end

end
