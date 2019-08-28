require 'test_helper'

class CustomFormsPlugin::DateTimeFieldTest < ActiveSupport::TestCase
  should 'validate type' do
    datetime = CustomFormsPlugin::DateTimeField.new()

    datetime.update_attribute(:show_as, 'datetime')
    assert datetime.invalid?

  end

  should 'field type defaults to datetime when initialized' do
    datetime = CustomFormsPlugin::DateTimeField.new()
    assert_equal 'datetime', datetime.show_as
  end
end
