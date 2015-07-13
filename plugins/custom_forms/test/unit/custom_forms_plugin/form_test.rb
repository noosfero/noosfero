require 'test_helper'

class CustomFormsPlugin::FormTest < ActiveSupport::TestCase
  should 'validates presence of a profile and a name' do
    form = CustomFormsPlugin::Form.new
    form.valid?
    assert form.errors.include?(:profile)
    assert form.errors.include?(:name)

    form.profile = fast_create(Profile)
    form.name = 'Free Software'
    form.valid?
    assert !form.errors.include?(:profile)
    assert !form.errors.include?(:name)
  end

  should 'have many fields including fields subclasses' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile), :name => 'Free Software')
    f1 = CustomFormsPlugin::Field.create!(:form => form, :name => 'License')
    f2 = CustomFormsPlugin::Field.create!(:form => form, :name => 'Code')
    f3 = CustomFormsPlugin::TextField.create!(:form => form, :name => 'Developer')

    assert_includes form.fields, f1
    assert_includes form.fields, f2
    assert_includes form.fields, f3
  end

  should 'have many submissions' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile), :name => 'Free Software')
    s1 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    s2 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))

    assert_includes form.submissions, s1
    assert_includes form.submissions, s2
  end

  should 'set slug before validation based on name' do
    form = CustomFormsPlugin::Form.new(:name => 'Name')
    form.valid?
    assert_equal form.name.to_slug, form.slug
  end

  should 'validates uniqueness of slug scoped on profile' do
    profile = fast_create(Profile)
    another_profile = fast_create(Profile)
    CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    form = CustomFormsPlugin::Form.new(:profile => profile, :name => 'Free Software')
    form.valid?
    assert form.errors.include?(:slug)

    form.profile = another_profile
    form.valid?
    assert !form.errors.include?(:slug)
  end

  should 'validate the difference between ending and beginning is positive' do
    profile = fast_create(Profile)
    form = CustomFormsPlugin::Form.new(:profile => profile, :name => 'Free Software')

    form.begining = Time.now
    form.ending = Time.now + 1.day
    assert form.valid?
    assert !form.errors.include?(:base)

    form.ending = Time.now - 2.day
    assert !form.valid?
    assert form.errors.include?(:base)
  end

  should 'define form expiration' do
    form = CustomFormsPlugin::Form.new
    assert !form.expired?

    form.begining = Time.now + 1.day
    assert form.expired?

    form.begining = Time.now - 1.day
    assert !form.expired?

    form.begining = nil
    form.ending = Time.now + 1.day
    assert !form.expired?

    form.ending = Time.now - 1.day
    assert form.expired?

    form.begining = Time.now - 1.day
    form.ending = Time.now + 1.day
    assert !form.expired?
  end

  should 'define if form will still open' do
    form = CustomFormsPlugin::Form.new
    assert !form.will_open?

    form.begining = Time.now + 1.day
    assert form.will_open?

    form.begining = Time.now - 1.day
    assert !form.will_open?

    form.begining = Time.now - 2.day
    form.ending = Time.now - 1.day
    assert form.expired?
    assert !form.will_open?
  end

  should 'validates format of access' do
    form = CustomFormsPlugin::Form.new
    form.valid?
    assert !form.errors.include?(:access)

    form.access = 'bli'
    form.valid?
    assert form.errors.include?(:access)

    form.access = 'logged'
    form.valid?
    assert !form.errors.include?(:access)

    form.access = 'associated'
    form.valid?
    assert !form.errors.include?(:access)

    form.access = {:bli => 1}
    form.valid?
    assert form.errors.include?(:access)

    form.access = 999
    form.valid?
    assert form.errors.include?(:access)

    p1 = fast_create(Profile)
    form.access = p1.id
    form.valid?
    assert !form.errors.include?(:access)

    p2 = fast_create(Profile)
    p3 = fast_create(Profile)
    form.access = [p1,p2,p3].map(&:id)
    form.valid?
    assert !form.errors.include?(:access)
  end

  should 'defines who is able to access the form' do
    owner = fast_create(Community)
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => owner)
    assert form.accessible_to(nil)

    form.access = 'logged'
    assert !form.accessible_to(nil)
    person = fast_create(Person)
    assert form.accessible_to(person)

    form.access = 'associated'
    assert !form.accessible_to(person)
    owner.add_member(person)
    assert form.accessible_to(person)

    p1 = fast_create(Profile)
    form.access = p1.id
    assert !form.accessible_to(person)
    assert form.accessible_to(p1)

    p2 = fast_create(Profile)
    form.access = [person.id, p1.id]
    assert form.accessible_to(person)
    assert form.accessible_to(p1)
    assert !form.accessible_to(p2)
    form.access << p2.id
    assert form.accessible_to(p2)

    assert form.accessible_to(owner)
  end

  should 'have a scope that retrieve forms from a profile' do
    profile = fast_create(Profile)
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => profile)
    f2 = CustomFormsPlugin::Form.create!(:name => 'Open Source', :profile => profile)
    f3 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => another_profile)
    scope = CustomFormsPlugin::Form.from_profile(profile)

    assert_equal ActiveRecord::Relation, scope.class
    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'have a scope that retrieves all forms that are triggered on membership' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'On membership 1', :profile => profile, :on_membership => true)
    f2 = CustomFormsPlugin::Form.create!(:name => 'On membership 2', :profile => profile, :on_membership => true)
    f3 = CustomFormsPlugin::Form.create!(:name => 'Not on memberhsip', :profile => profile, :on_membership => false)
    scope = CustomFormsPlugin::Form.from_profile(profile).on_memberships

    assert_equal ActiveRecord::Relation, scope.class
    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'destroy fields after removing a form' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    license_field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)

    assert_difference 'CustomFormsPlugin::Field.count', -2 do
      form.destroy
    end
  end

  should 'sort fields by position' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    license_field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form, :position => 2)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form, :position => 0)

    assert_equal form.fields, [url_field, license_field]
  end

  should 'have a scope that retrieves all forms required for membership' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'For admission 1', :profile => profile, :for_admission => true)
    f2 = CustomFormsPlugin::Form.create!(:name => 'For admission 2', :profile => profile, :for_admission => true)
    f3 = CustomFormsPlugin::Form.create!(:name => 'Not for admission', :profile => profile, :for_admission => false)
    scope = CustomFormsPlugin::Form.from_profile(profile).for_admissions

    assert_equal ActiveRecord::Relation, scope.class
    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'not include admission membership in on membership named scope' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'On membership', :profile => profile, :on_membership => true)
    f2 = CustomFormsPlugin::Form.create!(:name => 'For admission', :profile => profile, :on_membership => true, :for_admission => true)
    scope = CustomFormsPlugin::Form.from_profile(profile).on_memberships

    assert_equal ActiveRecord::Relation, scope.class
    assert_includes scope, f1
    assert_not_includes scope, f2
  end

  should 'cancel survey tasks after removing a form' do
    profile = fast_create(Profile)
    person = create_user('john').person

    form1 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => profile)
    form2 = CustomFormsPlugin::Form.create!(:name => 'Operation System', :profile => profile)

    task1 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form1.id, :target => person, :requestor => profile)
    task2 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form2.id, :target => person, :requestor => profile)

    assert_includes Task.opened, task1
    assert_includes Task.opened, task2
    form1.destroy
    assert_includes Task.canceled, task1
    assert_includes Task.opened, task2
    form2.destroy
    assert_includes Task.canceled, task2
  end

  should 'destroy submissions after form is destroyed' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile), :name => 'Free Software')
    s1 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    s2 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    form.destroy

    assert_raise ActiveRecord::RecordNotFound do
      s1.reload
    end
    assert_raise ActiveRecord::RecordNotFound do
      s2.reload
    end
  end

  should 'destroy forms after profile is destroyed' do
    profile = fast_create(Profile)
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    profile.destroy

    assert_raise ActiveRecord::RecordNotFound do
      CustomFormsPlugin::Form.find(form.id)
    end
  end

end
