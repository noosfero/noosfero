require File.dirname(__FILE__) + '/../test_helper'

class LightboxHelperTest < ActiveSupport::TestCase

  include LightboxHelper

  def setup
    stubs(:_).with(anything).returns('TEXT')
  end

  should 'provide the needed files' do
    assert File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', 'lightbox.css')), 'lightbox.css expected to be in public/stylesheets, but not found'
    assert File.exists?(File.join(RAILS_ROOT, 'public', 'javascripts', 'lightbox.js')), 'lightbox.js expected to be in public/javascripts, but not found'
  end

  should 'provide lightbox_link_to helper' do
    expects(:link_to).with('text', { :action => 'view', :id => '1' }, has_entries({ :class => 'lbOn', :id => 'my-link' })).returns('[link]')
    assert_equal '[link]', lightbox_link_to('text', { :action => 'view', :id => '1'}, { :id => 'my-link' })
  end

  should 'merge existing :class option in lightbox_link_to' do
    expects(:link_to).with('text', { :action => 'view', :id => '1' }, has_entries({ :class => 'lbOn my-button', :id => 'my-link' })).returns('[link]')
    assert_equal '[link]', lightbox_link_to('text', { :action => 'view', :id => '1'}, { :class => 'my-button',  :id => 'my-link' })

  end

  should 'provide link to close lightbox' do
    expects(:button).with(:close, 'text', '#', has_entries({ :class => 'lbAction', :rel => 'deactivate', :id => 'my-id' })).returns('[close-lightbox]')

    assert_equal '[close-lightbox]', lightbox_close_button('text', :id => 'my-id')
  end

  should 'merge existing :class option in lightbox_close_button' do
    expects(:button).with(:close, 'text', '#', has_entries({ :class => 'lbAction my-class', :rel => 'deactivate', :id => 'my-id' })).returns('[close-lightbox]')

    assert_equal '[close-lightbox]', lightbox_close_button('text', :class => 'my-class', :id => 'my-id' )
  end

  should 'provide lightbox_button' do
    expects(:button).with('type', 'label', { :action => 'popup'}, has_entries({ :class => 'lbOn' })).returns('[button]')

    assert_equal '[button]', lightbox_button('type', 'label', { :action => 'popup'})
  end

  should 'provide lightbox_icon_button' do
    expects(:icon_button).with('type', 'label', { :action => 'popup'}, has_entries({ :class => 'lbOn' })).returns('[button]')

    assert_equal '[button]', lightbox_icon_button('type', 'label', { :action => 'popup'})
  end

  should 'tell if rendering inside lightbox' do
    request = mock
    expects(:request).returns(request)
    request.expects(:xhr?).returns(true)

    assert lightbox?
  end

  should 'provide lightbox_remote_button' do
    expects(:button).with('type', 'label', { :action => 'popup'}, has_entries({ :class => 'remote-lbOn' })).returns('[button]')

    assert_equal '[button]', lightbox_remote_button('type', 'label', { :action => 'popup'})
  end

end
