require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::SelectFieldTest < ActiveSupport::TestCase
  should 'validate presence of choices, multiple and list' do
    select = CustomFormsPlugin::SelectField.new
    select.valid?
    assert select.errors.invalid?(:choices)

    select.choices = {'label' => 'value'}
    select.valid?
    assert !select.errors.invalid?(:choices)
  end
end
