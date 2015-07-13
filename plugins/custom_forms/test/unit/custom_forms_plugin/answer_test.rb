require 'test_helper'

class CustomFormsPlugin::AnswerTest < ActiveSupport::TestCase
  should 'validates presence of field' do
    answer = CustomFormsPlugin::Answer.new
    answer.valid?
    assert answer.errors.include?(:field)

    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    answer.field = field
    answer.valid?
    assert !answer.errors.include?(:field)
  end

  should 'belong to a submission' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    submission = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    answer = CustomFormsPlugin::Answer.new
    answer.submission = submission

    assert_equal submission, answer.submission
  end

  should 'require presence of value if field is mandatory' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form, :mandatory => true)
    answer = CustomFormsPlugin::Answer.new(:field => field)
    answer.valid?
    assert answer.errors.include?(:value)

    answer.value = "GPL"
    answer.valid?
    assert !answer.errors.include?(:value)
  end

  should 'make string representation show answers' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'ProjectName', :form => form)
    answer = CustomFormsPlugin::Answer.new(:field => field, :value => 'MyProject')

    field_select = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    alt = CustomFormsPlugin::Alternative.create!(:id => 1, :field => field_select, :label => 'GPL')
    answer2 = CustomFormsPlugin::Answer.new(:field => field_select, :value => alt.id.to_s)

    assert_equal 'MyProject', answer.to_s
    assert_equal 'GPL', answer2.to_s
  end

end

