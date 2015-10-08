require 'test_helper'

class CustomFormsPlugin::SelectFieldTest < ActiveSupport::TestCase
  should 'have alternative' do
    select = CustomFormsPlugin::SelectField.new(:name => 'select_field001' )
    refute select.save

    select.alternatives << CustomFormsPlugin::Alternative.new(:label => 'option')
    assert select.save
  end

  should 'validate type' do
    select = CustomFormsPlugin::SelectField.new(:name => 'select_field001' )
    select.alternatives << CustomFormsPlugin::Alternative.new(:label => 'option')

    select.update_attribute(:show_as, 'random')
    assert select.invalid?

    select.update_attribute(:show_as, 'radio')
    assert select.valid?
    select.update_attribute(:show_as, 'check_box')
    assert select.valid?
    select.update_attribute(:show_as, 'select')
    assert select.valid?
    select.update_attribute(:show_as, 'multiple_select')
    assert select.valid?
  end
end
