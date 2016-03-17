require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::TextFieldTest < ActiveSupport::TestCase
  should 'validate type' do
    text = CustomFormsPlugin::TextField.new(:name => 'text-field-010' )

    text.update_attribute(:show_as, 'random')
    assert text.invalid?
    text.update_attribute(:show_as, 'radio')
    assert text.invalid?

    text.update_attribute(:show_as, 'text')
    assert text.valid?
    text.update_attribute(:show_as, 'textarea')
    assert text.valid?
  end

  should 'field type defaults to text when initialized' do
    text = CustomFormsPlugin::TextField.new(:name => 'text_field001' )
    assert_equal 'text', text.show_as
  end
end
