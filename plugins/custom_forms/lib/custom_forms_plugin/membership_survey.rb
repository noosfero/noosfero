class CustomFormsPlugin::MembershipSurvey < Task

  settings_items :form_id, :submission
  validates_presence_of :form_id

  include CustomFormsPlugin::Helper

  def perform
    form = CustomFormsPlugin::Form.find(form_id)
    answers = build_answers(submission, form)
    s = CustomFormsPlugin::Submission.create!(:form => form, :profile => target)
    answers.map {|answer| answer.submission = s; answer.save!}
  end

  def title
    _("Membership survey")
  end

  def subject
    nil
  end

  def linked_subject
    nil
  end

  def information
    {:message => _('%{requestor} wants you to fill in some information.')}
  end

  def accept_details
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def target_notification_message
    _('After joining %{requestor}, the administrators of this organization
      wants you to fill in some further information.') % {:requestor => requestor.name}
  end

  def target_notification_description
    _('%{requestor} wants to fill in some further information.') % {:requestor => requestor.name}
  end
end
