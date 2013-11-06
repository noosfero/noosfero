require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::SelectFieldTest < ActiveSupport::TestCase
  should 'have alternative' do
    select = CustomFormsPlugin::SelectField.new(:name => 'select_field001' )
    assert !select.save

    select.alternatives << CustomFormsPlugin::Alternative.new(:label => 'option')
    assert select.save
  end

  should 'validate type' do
    select = CustomFormsPlugin::SelectField.new(:name => 'select_field001' )
    select.alternatives << CustomFormsPlugin::Alternative.new(:label => 'option')

    select.update_attribute(:select_field_type, 'random')
    assert select.invalid?

    select.update_attribute(:select_field_type, 'radio')
    assert select.valid?
    select.update_attribute(:select_field_type, 'check_box')
    assert select.valid?
    select.update_attribute(:select_field_type, 'select')
    assert select.valid?
    select.update_attribute(:select_field_type, 'multiple_select')
    assert select.valid?
  end
end
