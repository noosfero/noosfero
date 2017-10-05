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
    refute form.errors.include?(:profile)
    refute form.errors.include?(:name)
  end

  should 'have many fields including fields subclasses' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    f1 = CustomFormsPlugin::Field.create!(:form => form,
                                          :name => 'License')
    f2 = CustomFormsPlugin::Field.create!(:form => form, :name => 'Code')
    f3 = CustomFormsPlugin::TextField.create!(:form => form,
                                              :name => 'Developer')

    assert_includes form.fields, f1
    assert_includes form.fields, f2
    assert_includes form.fields, f3
  end

  should 'have many submissions' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    s1 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    s2 = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))

    assert_includes form.submissions, s1
    assert_includes form.submissions, s2
  end

  should 'set slug amd identifier before validation based on name' do
    form = CustomFormsPlugin::Form.new(:name => 'Name', :identifier => 'name')
    form.valid?
    assert_equal form.name.to_slug, form.slug
    assert_equal form.name.to_slug, form.identifier
  end

  should 'validates uniqueness of slug scoped on profile' do
    profile = fast_create(Profile)
    another_profile = fast_create(Profile)
    CustomFormsPlugin::Form.create!(:profile => profile,
                                    :name => 'Free Software',
                                    :identifier => 'free')
    form = CustomFormsPlugin::Form.create(:profile => profile,
                                          :name => 'Free Software',
                                          :identifier => 'free')
    form.valid?
    assert form.errors.include?(:slug)

    form.profile = another_profile
    form.valid?
    refute form.errors.include?(:slug)
  end

  should 'validate the difference between ending and beginning is positive' do
    profile = fast_create(Profile)
    form = CustomFormsPlugin::Form.new(:profile => profile,
                                       :name => 'Free Software',
                                       :identifier => 'free2')

    form.begining = Time.now
    form.ending = Time.now + 1.day
    assert form.valid?
    refute form.errors.include?(:base)

    form.ending = Time.now - 2.day
    refute form.valid?
    assert form.errors.include?(:base)
  end

  should 'have survey as default kind' do
    form = CustomFormsPlugin::Form.new
    assert_equal 'survey', form.kind
  end

  should 'validate kinds' do
    poll = CustomFormsPlugin::Form.new(kind: 'poll')
    survey = CustomFormsPlugin::Form.new(kind: 'survey')
    other = CustomFormsPlugin::Form.new(kind: 'other')

    poll.valid?
    survey.valid?
    other.valid?

    assert poll.errors[:kind].blank?
    assert survey.errors[:kind].blank?
    refute other.errors[:kind].blank?
  end

  should 'define form expiration' do
    form = CustomFormsPlugin::Form.new
    refute form.expired?

    form.begining = Time.now + 1.day
    assert form.expired?

    form.begining = Time.now - 1.day
    refute form.expired?

    form.begining = nil
    form.ending = Time.now + 1.day
    refute form.expired?

    form.ending = Time.now - 1.day
    assert form.expired?

    form.begining = Time.now - 1.day
    form.ending = Time.now + 1.day
    refute form.expired?
  end

  should 'define if form will still open' do
    form = CustomFormsPlugin::Form.new
    refute form.will_open?

    form.begining = Time.now + 1.day
    assert form.will_open?

    form.begining = Time.now - 1.day
    refute form.will_open?

    form.begining = Time.now - 2.day
    form.ending = Time.now - 1.day
    assert form.expired?
    refute form.will_open?
  end

  should 'validates format of access' do
    form = CustomFormsPlugin::Form.new
    form.valid?
    refute form.errors.include?(:access)

    form.access = 'bli'
    form.valid?
    assert form.errors.include?(:access)

    form.access = 'logged'
    form.valid?
    refute form.errors.include?(:access)

    form.access = 'associated'
    form.valid?
    refute form.errors.include?(:access)

    form.access = {:bli => 1}
    form.valid?
    assert form.errors.include?(:access)

    form.access = 999
    form.valid?
    assert form.errors.include?(:access)

    p1 = fast_create(Profile)
    form.access = p1.id
    form.valid?
    refute form.errors.include?(:access)

    p2 = fast_create(Profile)
    p3 = fast_create(Profile)
    form.access = [p1,p2,p3].map(&:id)
    form.valid?
    refute form.errors.include?(:access)
  end

  should 'defines who is able to access the form' do
    owner = fast_create(Community)
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                           :profile => owner,
                                           :identifier => 'free')
    assert form.accessible_to(nil)

    form.access = 'logged'
    refute form.accessible_to(nil)
    person = fast_create(Person)
    assert form.accessible_to(person)

    form.access = 'associated'
    refute form.accessible_to(person)
    owner.add_member(person)
    assert form.accessible_to(person)

    p1 = fast_create(Profile)
    form.access = p1.id
    refute form.accessible_to(person)
    assert form.accessible_to(p1)

    p2 = fast_create(Profile)
    form.access = [person.id, p1.id]
    assert form.accessible_to(person)
    assert form.accessible_to(p1)
    refute form.accessible_to(p2)
    form.access << p2.id
    assert form.accessible_to(p2)

    assert form.accessible_to(owner)
  end

  should 'have a scope that retrieve forms from a profile' do
    profile = fast_create(Profile)
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                         :profile => profile,
                                         :identifier => 'free')
    f2 = CustomFormsPlugin::Form.create!(:name => 'Open Source',
                                         :profile => profile,
                                         :identifier => 'open')
    f3 = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                         :profile => another_profile,
                                         :identifier => 'free1')
    scope = CustomFormsPlugin::Form.from_profile(profile)

    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'have a scope that retrieves all forms that are triggered on membership' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'On membership 1',
                                         :profile => profile,
                                         :on_membership => true,
                                         :identifier => 'onMemb1')
    f2 = CustomFormsPlugin::Form.create!(:name => 'On membership 2',
                                         :profile => profile,
                                         :on_membership => true,
                                         :identifier => 'onMemb2')
    f3 = CustomFormsPlugin::Form.create!(:name => 'Not on memberhsip',
                                         :profile => profile,
                                         :on_membership => false,
                                         :identifier => 'NotOnMemb')
    scope = CustomFormsPlugin::Form.from_profile(profile).on_memberships

    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'destroy fields after removing a form' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                           :profile => fast_create(Profile),
                                           :identifier => 'free')
    license_field = CustomFormsPlugin::Field.create!(:name => 'License',
                                                     :form => form)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL',
                                                 :form => form)

    assert_difference 'CustomFormsPlugin::Field.count', -2 do
      form.destroy
    end
  end

  should 'sort fields by position' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                           :profile => fast_create(Profile),
                                           :identifier => 'free')
    license_field = CustomFormsPlugin::Field.create!(:name => 'License',
                                                     :form => form,
                                                     :position => 2)
    url_field = CustomFormsPlugin::Field.create!(:name => 'URL',
                                                 :form => form,
                                                 :position => 0)

    assert_equal form.fields, [url_field, license_field]
  end

  should 'have a scope that retrieves all forms required for membership' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'For admission 1',
                                         :profile => profile,
                                         :for_admission => true,
                                         :identifier => 'for1')
    f2 = CustomFormsPlugin::Form.create!(:name => 'For admission 2',
                                         :profile => profile,
                                         :for_admission => true,
                                         :identifier => 'for2')
    f3 = CustomFormsPlugin::Form.create!(:name => 'Not for admission',
                                         :profile => profile,
                                         :for_admission => false,
                                         :identifier => 'NotFor')
    scope = CustomFormsPlugin::Form.from_profile(profile).for_admissions

    assert_includes scope, f1
    assert_includes scope, f2
    assert_not_includes scope, f3
  end

  should 'have a scope that retrieve forms from a kind' do
    profile = fast_create(Profile)
    survey = CustomFormsPlugin::Form.create!(:name => 'Free Software', :identifier => 'free-software', :profile => profile, :kind => 'survey')
    poll = CustomFormsPlugin::Form.create!(:name => 'Open Source', :identifier => 'open-source', :profile => profile, :kind => 'poll')

    assert_includes CustomFormsPlugin::Form.by_kind(:survey), survey
    assert_not_includes CustomFormsPlugin::Form.by_kind(:survey), poll
    assert_includes CustomFormsPlugin::Form.by_kind(:poll), poll
    assert_not_includes CustomFormsPlugin::Form.by_kind(:poll), survey
  end


  should 'have a scope that retrieve forms by a status' do
    profile = fast_create(Profile)
    opened_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Opened Survey', :identifier => 'opened-survey', :begining => Time.now - 1.day)
    closed_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Closed Survey', :identifier => 'closed-survey', :ending => Time.now - 1.day)
    to_come_survey = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'To Come Survey', :identifier => 'to-come-survey', :begining => Time.now + 1.day)

    invalid_status = profile.forms.by_status('invalid_status')
    assert_includes invalid_status, opened_survey
    assert_includes invalid_status, closed_survey
    assert_includes invalid_status, to_come_survey

    opened = profile.forms.by_status('opened')
    assert_includes opened, opened_survey
    assert_not_includes opened, closed_survey
    assert_not_includes opened, to_come_survey

    closed = profile.forms.by_status('closed')
    assert_not_includes closed, opened_survey
    assert_includes closed, closed_survey
    assert_not_includes closed, to_come_survey

    to_come = profile.forms.by_status('to-come')
    assert_not_includes to_come, opened_survey
    assert_not_includes to_come, closed_survey
    assert_includes to_come, to_come_survey
  end

  should 'not include admission membership in on membership named scope' do
    profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:name => 'On membership',
                                         :profile => profile,
                                         :on_membership => true,
                                         :identifier => 'membership1')
    f2 = CustomFormsPlugin::Form.create!(:name => 'For admission',
                                         :profile => profile,
                                         :on_membership => true,
                                         :for_admission => true,
                                         :identifier  => 'for-adm')
    scope = CustomFormsPlugin::Form.from_profile(profile).on_memberships

    assert_includes scope, f1
    assert_not_includes scope, f2
  end

  should 'cancel survey tasks after removing a form' do
    profile = fast_create(Profile)
    person = create_user('john').person

    form1 = CustomFormsPlugin::Form.create!(:name => 'Free Software',
                                            :profile => profile,
                                            :identifier => 'free')
    form2 = CustomFormsPlugin::Form.create!(:name => 'Operation System',
                                            :profile => profile,
                                            :identifier => 'open')

    task1 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form1.id,
                                                        :target => person,
                                                        :requestor => profile)
    task2 = CustomFormsPlugin::MembershipSurvey.create!(:form_id => form2.id,
                                                        :target => person,
                                                        :requestor => profile)

    assert_includes Task.opened, task1
    assert_includes Task.opened, task2
    form1.destroy
    assert_includes Task.canceled, task1
    assert_includes Task.opened, task2
    form2.destroy
    assert_includes Task.canceled, task2
  end

  should 'destroy submissions after form is destroyed' do
    form = CustomFormsPlugin::Form.create!(:profile => fast_create(Profile),
                                           :name => 'Free Software',
                                           :identifier => 'free')
    s1 = CustomFormsPlugin::Submission.create!(:form => form,
                                               :profile => fast_create(Profile))
    s2 = CustomFormsPlugin::Submission.create!(:form => form,
                                               :profile => fast_create(Profile))
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
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'free')
    profile.destroy

    assert_raise ActiveRecord::RecordNotFound do
      CustomFormsPlugin::Form.find(form.id)
    end
  end

  should 'have a unique identifier' do
    profile = fast_create(Profile)
    CustomFormsPlugin::Form.create!(:profile => profile,
                                    :name => 'Free Software',
                                    :identifier => 'free-software')

    form_error = CustomFormsPlugin::Form.new(:profile => profile,
                                             :name => 'Free Software2',
                                             :identifier => 'free-software')
    assert_raise ActiveRecord::RecordInvalid do
      form_error.save!
    end
  end

  should 'add a UploadedFile to a form' do
    profile = fast_create(Profile)
    form = CustomFormsPlugin::Form.new(:profile => profile,
                                       :name => 'Free Software',
                                       :identifier => 'free')
    form.build_article(:name => 'my_image')
    form.save!

    assert_not_nil form.image
    assert_instance_of UploadedFile, form.image
  end

  should 'get forms by scope' do
    profile = fast_create(Profile)
    forms = [{
              :profile => profile, :name => 'Free Software',
              :identifier => 'free-software',
              :access_result_options => 'public'
             },
             {
              :profile => profile, :name => 'Free Software 2',
              :identifier => 'free-software-2',
              :access_result_options => 'public'
             },
             {
              :profile => profile, :name => 'Free Software 3',
              :identifier => 'free-software-3',
              :access_result_options => 'private'
             },
             {
              :profile => profile, :name => 'Free Software 4',
              :identifier => 'free-software-4',
              :access_result_options => 'public_after_ends'
             }
    ]

    forms.each do |form|
      CustomFormsPlugin::Form.create!(form)
    end

    assert_equal CustomFormsPlugin::Form.with_public_results().count, 2
    assert_equal CustomFormsPlugin::Form.with_private_results().count, 1
    assert_equal CustomFormsPlugin::Form.with_public_results_after_ends().count, 1
    end
  end
