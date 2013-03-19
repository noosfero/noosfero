require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::FormTest < ActiveSupport::TestCase
  should 'validates presence of a profile and a name' do
    form = CustomFormsPlugin::Form.new
    form.valid?
    assert form.errors.invalid?(:profile)
    assert form.errors.invalid?(:name)

    form.profile = fast_create(Profile)
    form.name = 'Free Software'
    form.valid?
    assert !form.errors.invalid?(:profile)
    assert !form.errors.invalid?(:name)
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
    assert form.errors.invalid?(:slug)

    form.profile = another_profile
    form.valid?
    assert !form.errors.invalid?(:slug)
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

  should 'validates format of access' do
    form = CustomFormsPlugin::Form.new
    form.valid?
    assert !form.errors.invalid?(:access)

    form.access = 'bli'
    form.valid?
    assert form.errors.invalid?(:access)

    form.access = 'logged'
    form.valid?
    assert !form.errors.invalid?(:access)

    form.access = 'associated'
    form.valid?
    assert !form.errors.invalid?(:access)

    form.access = {:bli => 1}
    form.valid?
    assert form.errors.invalid?(:access)

    form.access = 999
    form.valid?
    assert form.errors.invalid?(:access)

    p1 = fast_create(Profile)
    form.access = p1.id
    form.valid?
    assert !form.errors.invalid?(:access)

    p2 = fast_create(Profile)
    p3 = fast_create(Profile)
    form.access = [p1,p2,p3].map(&:id)
    form.valid?
    assert !form.errors.invalid?(:access)
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

  should 'have a named_scope that retrieve forms from a profile' do
    profile = fast_create(Profile)
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => profile)
    f2 = CustomFormsPlugin::Form.create!(:name => 'Open Source', :profile => profile)
    f3 = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => another_profile)
    scope = CustomFormsPlugin::Form.from(profile)

    assert_equal ActiveRecord::NamedScope::Scope, scope.class
    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'have a named_scope that retrieves all forms that are triggered on membership' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'On membership 1', :profile => profile, :on_membership => true)
    f2 = CustomFormsPlugin::Form.create!(:name => 'On membership 2', :profile => profile, :on_membership => true)
    f3 = CustomFormsPlugin::Form.create!(:name => 'Not on memberhsip', :profile => profile, :on_membership => false)
    scope = CustomFormsPlugin::Form.from(profile).on_memberships

    assert_equal ActiveRecord::NamedScope::Scope, scope.class
    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'destroy fields after removing a form' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    license_field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL', :form => form)

    assert_difference CustomFormsPlugin::Field, :count, -2 do
      form.destroy
    end
  end

end
