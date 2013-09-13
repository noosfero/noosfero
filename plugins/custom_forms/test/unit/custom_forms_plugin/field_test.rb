require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::FieldTest < ActiveSupport::TestCase
  should 'set slug before validation based on name' do
    field = CustomFormsPlugin::Field.new(:name => 'Name')
    field.valid?
    assert_equal field.name.to_slug, field.slug
  end

  should 'set mandatory field as false by default' do
    field = CustomFormsPlugin::Field.new
    assert !field.mandatory
  end

  should 'have answers' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    a1 = CustomFormsPlugin::Answer.create!(:field => field)
    a2 = CustomFormsPlugin::Answer.create!(:field => field)

    assert_includes field.answers, a1
    assert_includes field.answers, a2
  end

  should 'not destroy form after removing a field' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    license_field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)

    assert_no_difference CustomFormsPlugin::Form, :count do
      url_field.destroy
    end
    assert_equal form.fields, [license_field]
  end
end

