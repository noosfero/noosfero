require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::MembershipSurveyTest < ActiveSupport::TestCase
  should 'validates presence of form_id' do
    task = CustomFormsPlugin::MembershipSurvey.new
    task.valid?
    assert task.errors.invalid?(:form_id)

    task.form_id = 1
    task.valid?
    assert !task.errors.invalid?(:form_id)
  end

  should 'create submission with answers on perform' do
    profile = fast_create(Profile)
    person = fast_create(Person)
    form = CustomFormsPlugin::Form.create!(:name => 'Simple Form', :profile => profile)
    field = CustomFormsPlugin::Field.create!(:name => 'Name', :form => form)
    task = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form.id, :submission => {'name' => 'Jack'}, :target => person, :requestor => profile)

    assert_difference CustomFormsPlugin::Submission, :count, 1 do
      task.finish
    end

    submission = CustomFormsPlugin::Submission.last
    assert_equal submission.answers.count, 1 

    answer = submission.answers.first
    assert_equal answer.value, 'Jack'
  end
end
