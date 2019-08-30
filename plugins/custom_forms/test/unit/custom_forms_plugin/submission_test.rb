require "test_helper"

class CustomFormsPlugin::SubmissionTest < ActiveSupport::TestCase
  def setup
    @profile = fast_create(Profile)
  end
  attr_reader :profile

  should "validates presence of form" do
    submission = CustomFormsPlugin::Submission.new
    submission.valid?
    assert submission.errors.include?(:form)

    form = CustomFormsPlugin::Form.create!(profile: profile,
                                           name: "Simple form",
                                           identifier: "free")
    submission.form = form
    submission.valid?
    refute submission.errors.include?(:form)
  end

  should "belong to a profile" do
    submission = CustomFormsPlugin::Submission.new
    submission.profile = profile
    assert_equal profile, submission.profile
  end

  should "require presence of author name and email if profile is nil" do
    submission = CustomFormsPlugin::Submission.new
    submission.valid?
    assert submission.errors.include?(:author_name)
    assert submission.errors.include?(:author_email)

    submission.author_name = "Jack Sparrow"
    submission.author_email = "jack@black-pearl.com"
    submission.valid?
    refute submission.errors.include?(:author_name)
    refute submission.errors.include?(:author_email)
  end

  should "have answers" do
    form = CustomFormsPlugin::Form.create!(profile: profile,
                                           name: "Free Software",
                                           identifier: "free")
    field = CustomFormsPlugin::Field.create!(name: "License", form: form)
    submission = CustomFormsPlugin::Submission.create!(form: form, profile: profile)
    a1 = submission.answers.create!(field: field, submission: submission)
    a2 = submission.answers.create!(field: field, submission: submission)

    assert_includes submission.answers, a1
    assert_includes submission.answers, a2
  end

  should "store profile name as author" do
    form = CustomFormsPlugin::Form.create!(profile: profile,
                                           name: "Simple form",
                                           identifier: "free")
    submission = CustomFormsPlugin::Submission.create(form: form, profile: profile)

    assert_equal profile.name, submission.author_name
  end

  should "return the answer for a specific field" do
    form = CustomFormsPlugin::Form.create!(profile: profile,
                                           name: "Free Software",
                                           identifier: "free")
    field = CustomFormsPlugin::Field.create!(name: "License", form: form)
    submission = form.submissions.create!(profile: profile)
    answer = submission.answers.create!(field: field, submission: submission)
    assert_equal answer, submission.answer_for(field)
  end
end
