require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::FieldTest < ActiveSupport::TestCase
  should 'validate presence of form' do
    field = CustomFormsPlugin::Field.new
    field.valid?
    assert field.errors.invalid?(:form)
    assert field.errors.invalid?(:name)

    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field.form = form
    field.name = 'License'
    field.valid?
    assert !field.errors.invalid?(:form)
    assert !field.errors.invalid?(:name)
  end

  should 'set slug before validation based on name' do
    field = CustomFormsPlugin::Field.new(:name => 'Name')
    field.valid?
    assert_equal field.name.to_slug, field.slug
  end

  should 'validate uniqueness of slug scoped on the form' do
    form1 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    form2 = CustomFormsPlugin::Form.create!(:name => 'Open Source', :profile => fast_create(Profile))
    f1 = CustomFormsPlugin::Field.create!(:name => 'License', :form => form1)
    f2 = CustomFormsPlugin::Field.new(:name => 'License', :form => form1)
    f3 = CustomFormsPlugin::Field.new(:name => 'License', :form => form2)

    f2.valid?
    f3.valid?

    assert f2.errors.invalid?(:slug)
    assert !f3.errors.invalid?(:slug)
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

  should 'serialize choices into a hash' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    field.choices = {'First' => 1, 'Second' => 2, 'Third' => 3}
    field.save!

    assert_equal 1, field.choices['First']
    assert_equal 2, field.choices['Second']
    assert_equal 3, field.choices['Third']
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

  should 'give positions by creation order' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field_0 = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    field_1 = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)
    field_2 = CustomFormsPlugin::Field.create!(:name => 'Wiki', :form => form)
    assert_equal 0, field_0.position
    assert_equal 1, field_1.position
    assert_equal 2, field_2.position
  end

  should 'not crash when adding new fields on a form with fields without position' do
    form = CustomFormsPlugin::Form.create(:name => 'Free Software', :profile => fast_create(Profile))
    field_0 = CustomFormsPlugin::Field.create(:name => 'License', :form => form)
    field_0.position = nil
    field_0.save

    assert_nothing_raised do
      field_1 = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)
    end
  end

end

