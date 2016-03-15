# encoding: UTF-8
require_relative "../test_helper"

class ButtonsHelperTest < ActionView::TestCase
  include ButtonsHelper

  should 'append with-text class and keep existing classes' do
    expects(:button_without_text).with('type', 'label', 'url', { :class => 'with-text class1'})
    button('type', 'label', 'url', { :class => 'class1' })
  end
end