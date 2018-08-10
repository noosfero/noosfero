require 'test_helper'

class CustomFormsPlugin::FieldTest < ActiveSupport::TestCase
  should 'set slug before validation based on name' do
    field = CustomFormsPlugin::Field.new(:name => 'Name')
    field.valid?
    assert_equal field.name.to_slug, field.slug
  end

  should 'set mandatory field as false by default' do
    field = CustomFormsPlugin::Field.new
    refute field.mandatory
  end
  
  should 'set mandatory field as true when form type is a poll' do
    form = CustomFormsPlugin::Form.create!(profile: fast_create(Profile),
                                           name: 'Free Software',
                                           identifier: 'free',
                                           kind: 'poll')
    field = CustomFormsPlugin::Field.new(name: 'field', form: form)
    field.save!
    
    assert field.mandatory
  end

  should 'have answers' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    a1 = CustomFormsPlugin::Answer.create!(:field => field)
    a2 = CustomFormsPlugin::Answer.create!(:field => field)

    assert_includes field.answers, a1
    assert_includes field.answers, a2
  end

  should 'not destroy form after removing a field' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    license_field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)

    assert_no_difference 'CustomFormsPlugin::Form.count' do
      url_field.destroy
    end
    assert_equal form.fields, [license_field]
  end

  should 'destroy its answers after removing a field' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    field = CustomFormsPlugin::Field.create!(:name => 'Project name', :form => form)

    CustomFormsPlugin::Answer.create(:field => field, :value => 'My Project')
    CustomFormsPlugin::Answer.create(:field => field, :value => 'Other Project')

    assert_difference 'CustomFormsPlugin::Answer.count', -2 do
      field.destroy
    end
  end

  should 'have alternative if type is SelectField' do
    select = CustomFormsPlugin::Field.new(:name => 'select_field001', :type => 'CustomFormsPlugin::SelectField')
    refute select.save

    select.alternatives << CustomFormsPlugin::Alternative.new(:label => 'option')
    assert select.save
  end

  should 'sort alternatives by position' do
    field = CustomFormsPlugin::Field.create!(:name => 'field001')
    second = CustomFormsPlugin::Alternative.create!(:label => 'second', :field => field, :position => 2)
    first = CustomFormsPlugin::Alternative.create!(:label => 'first', :field => field, :position => 1)

    assert_equal field.alternatives, [first, second]
  end

  should 'create a summary based on answers' do
    form = CustomFormsPlugin::Form.create!(profile: fast_create(Profile),
                                           name: 'Free Software',
                                           identifier: 'free')
    field = CustomFormsPlugin::Field.create!(name: 'License', form: form)
    CustomFormsPlugin::Answer.create!(field: field, value: 'opt1')
    CustomFormsPlugin::Answer.create!(field: field, value: 'opt1', imported: true)
    CustomFormsPlugin::Answer.create!(field: field, value: 'opt2', imported: true)

    assert_equal({ online: 50, offline: 50}, field.summary['opt1'])
    assert_equal({ online: 0, offline: 100}, field.summary['opt2'])
  end
end

