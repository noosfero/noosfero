require File.dirname(__FILE__) + '/../test_helper'

class ColorboxHelperTest < ActiveSupport::TestCase

  include ColorboxHelper

  should 'provide the needed files' do
    assert File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', 'colorbox.css')), 'colorbox.css expected to be in public/stylesheets, but not found'
    assert File.exists?(File.join(RAILS_ROOT, 'public', 'javascripts', 'colorbox.js')), 'colorbox.js expected to be in public/javascripts, but not found'
  end

  should 'provide link to close colorbox' do
    expects(:button).with(:close, 'text', '#', has_entries({ :class => 'colorbox-close', :id => 'my-id' })).returns('[close-colorbox]')

    assert_equal '[close-colorbox]', colorbox_close_button('text', :id => 'my-id')
  end

  should 'merge existing :class option in colorbox_close_button' do
    expects(:button).with(:close, 'text', '#', has_entries({ :class => 'colorbox-close my-class', :id => 'my-id' })).returns('[close-colorbox]')

    assert_equal '[close-colorbox]', colorbox_close_button('text', :class => 'my-class', :id => 'my-id' )
  end

  should 'provide colorbox_button' do
    expects(:button).with('type', 'label', { :action => 'popup'}, has_entries({ :class => 'colorbox' })).returns('[button]')

    assert_equal '[button]', colorbox_button('type', 'label', { :action => 'popup'})
  end

  should 'provide colorbox_icon_button' do
    expects(:icon_button).with('type', 'label', { :action => 'popup'}, has_entries({ :class => 'colorbox' })).returns('[button]')

    assert_equal '[button]', colorbox_icon_button('type', 'label', { :action => 'popup'})
  end

end
