require 'test_helper'

class RoleAssignmentsTest < ActiveSupport::TestCase
  should 'create membership_surveys on membership creation' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = create_user('john').person
    f1 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 1', :on_membership => true)
    f2 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 2', :on_membership => true)
    f3 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 3', :on_membership => false)

    assert_difference 'CustomFormsPlugin::MembershipSurvey.count', 2 do
      organization.add_member(person)
    end
  end

  should 'create membership_survey on membership creation with form accessible to members only' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = create_user('john').person
    form = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form', :on_membership => true, :access => 'associated')

    assert_difference 'CustomFormsPlugin::MembershipSurvey.count', 1 do
      organization.add_member(person)
    end
  end

  should 'cancel surveys if membership is undone and task is active' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = create_user('john').person
    form1 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 1', :on_membership => true)
    organization.add_member(person)

    assert_difference 'CustomFormsPlugin::MembershipSurvey.pending.count', -1 do
      organization.remove_member(person)
    end

    form2 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 2', :for_admission => true)
    organization.add_member(person)

    assert_difference 'CustomFormsPlugin::AdmissionSurvey.pending.count', -1 do
      organization.remove_member(person)
    end

    organization.add_member(person)
    tasks = CustomFormsPlugin::MembershipSurvey.all.last(2)
    tasks.each {|t| t.status = Task::Status::FINISHED }
    tasks.each {|t| t.save! }
    assert_no_difference 'CustomFormsPlugin::MembershipSurvey.finished.count' do
      organization.remove_member(person)
    end
  end

  should 'create admission survey when atempted membership' do
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
    organization = fast_create(Organization)
    person = create_user('john').person
    f1 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 1', :for_admission => true)
    f2 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 2', :for_admission => true)
    f3 = CustomFormsPlugin::Form.create!(:profile => organization, :name => 'Form 3', :for_admission => false)

    assert_difference 'CustomFormsPlugin::AdmissionSurvey.count', 2 do
      organization.add_member(person)
    end
    assert !organization.members.include?(person)
  end
end
