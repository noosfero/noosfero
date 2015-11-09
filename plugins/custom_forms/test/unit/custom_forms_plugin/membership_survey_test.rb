require 'test_helper'

class CustomFormsPlugin::MembershipSurveyTest < ActiveSupport::TestCase
  should 'validates presence of form_id' do
    task = CustomFormsPlugin::MembershipSurvey.new
    task.valid?
    assert task.errors.include?(:form_id)

    task.form_id = 1
    task.valid?
    refute task.errors.include?(:form_id)
  end

  should 'create submission with answers on perform' do
    profile = fast_create(Profile)
    person = create_user('john').person
    form = CustomFormsPlugin::Form.create!(:name => 'Simple Form', :profile => profile)
    field = CustomFormsPlugin::Field.create!(:name => 'Name', :form => form)
    task = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form.id, :submission => {field.id.to_s => 'Jack'}, :target => person, :requestor => profile)

    assert_difference 'CustomFormsPlugin::Submission.count', 1 do
      task.finish
    end

    submission = CustomFormsPlugin::Submission.last
    assert_equal submission.answers.count, 1

    answer = submission.answers.first
    assert_equal answer.value, 'Jack'
  end

  should 'have a scope that retrieves all tasks requested by profile' do
    profile = fast_create(Profile)
    person = create_user('john').person
    form = CustomFormsPlugin::Form.create!(:name => 'Simple Form', :profile => profile)
    task1 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form.id, :target => person, :requestor => profile)
    task2 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form.id, :target => person, :requestor => fast_create(Profile))
    scope = CustomFormsPlugin::MembershipSurvey.from_profile(profile)

    assert_equal ActiveRecord::Relation, scope.class
    assert_includes scope, task1
    assert_not_includes scope, task2
  end
end
