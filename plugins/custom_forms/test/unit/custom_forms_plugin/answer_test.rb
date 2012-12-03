require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::AnswerTest < ActiveSupport::TestCase
  should 'validates presence of field' do
    answer = CustomFormsPlugin::Answer.new
    answer.valid?
    assert answer.errors.invalid?(:field)

    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    answer.field = field
    answer.valid?
    assert !answer.errors.invalid?(:field)
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
    assert answer.errors.invalid?(field.slug.to_sym)

    answer.value = "GPL"
    answer.valid?
    assert !answer.errors.invalid?(field.slug.to_sym)
  end

end

