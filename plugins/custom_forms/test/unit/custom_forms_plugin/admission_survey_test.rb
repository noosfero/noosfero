require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::AdmissionSurveyTest < ActiveSupport::TestCase
  should 'add member to community on perform' do
    profile = fast_create(Community)
    person = fast_create(Person)
    form = CustomFormsPlugin::Form.create!(:name => 'Simple Form', :profile => profile)
    task = CustomFormsPlugin::AdmissionSurvey.create!(:form_id => form.id, :target => person, :requestor => profile)

    assert_difference person.memberships, :count, 1 do
      task.finish
    end
  end
end
