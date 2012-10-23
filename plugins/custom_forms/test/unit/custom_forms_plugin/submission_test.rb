require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class CustomFormsPlugin::SubmissionTest < ActiveSupport::TestCase
  should 'validates presence of form' do
    submission = CustomFormsPlugin::Submission.new
    submission.valid?
    assert submission.errors.invalid?(:form)

    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    submission.form = form
    submission.valid?
    assert !submission.errors.invalid?(:form)
  end

  should 'belong to a profile' do
    profile = fast_create(Profile)
    submission = CustomFormsPlugin::Submission.new
    submission.profile = profile
    assert_equal profile, submission.profile
  end

  should 'require presence of author name and email if profile is nil' do
    submission = CustomFormsPlugin::Submission.new
    submission.valid?
    assert submission.errors.invalid?(:author_name)
    assert submission.errors.invalid?(:author_email)

    submission.author_name = 'Jack Sparrow'
    submission.author_email = 'jack@black-pearl.com'
    submission.valid?
    assert !submission.errors.invalid?(:author_name)
    assert !submission.errors.invalid?(:author_email)
  end

  should 'have answers' do
    form = CustomFormsPlugin::Form.create!(:name => 'Free Software', :profile => fast_create(Profile))
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    submission = CustomFormsPlugin::Submission.create!(:form => form, :profile => fast_create(Profile))
    a1 = CustomFormsPlugin::Answer.create!(:field => field, :submission => submission)
    a2 = CustomFormsPlugin::Answer.create!(:field => field, :submission => submission)

    assert_includes submission.answers, a1
    assert_includes submission.answers, a2
  end
end

