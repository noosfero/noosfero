require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class RoleAssignmentsTest < ActiveSupport::TestCase
  should 'create membership_surveys on membership creation' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = fast_create(Person)
    f1 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 1', :on_membership => true)
    f2 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 2', :on_membership => true)
    f3 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 3', :on_membership => false)

    assert_difference CustomFormsPlugin::MembershipSurvey, :count, 2 do
      organization.add_member(person)
    end
  end

  should 'create membership_survey on membership creation with form accessible to members only' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = fast_create(Person)
    form = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form', :on_membership => true, :access => 'associated')

    assert_difference CustomFormsPlugin::MembershipSurvey, :count, 1 do
      organization.add_member(person)
    end
  end

  should 'cancel membership_surveys if membership is undone and task is active' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = fast_create(Person)
    form = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form', :on_membership => true)
    organization.add_member(person)

    assert_difference CustomFormsPlugin::MembershipSurvey.pending, :count, -1 do
      organization.remove_member(person)
    end

    organization.add_member(person)
    task = CustomFormsPlugin::MembershipSurvey.last
    task.status = Task::Status::FINISHED
    task.save!
    assert_no_difference CustomFormsPlugin::MembershipSurvey.finished, :count do
      organization.remove_member(person)
    end
  end
end

