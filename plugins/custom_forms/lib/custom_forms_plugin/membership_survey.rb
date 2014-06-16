class CustomFormsPlugin::MembershipSurvey < Task

  settings_items :form_id, :submission
  validates_presence_of :form_id

  include CustomFormsPlugin::Helper

  scope :from, lambda {|profile| {:conditions => {:requestor_id => profile.id}}}

  def perform
    form = CustomFormsPlugin::Form.find(form_id)
    raise 'Form expired' if form.expired?

    answers = build_answers(submission, form)
    s = CustomFormsPlugin::Submission.create!(:form => form, :profile => target)
    s.answers.push(*answers)

    failed_answers = answers.select {|answer| !answer.valid? }
    if failed_answers.empty?
      s.save!
    else
      s.errors.clear
      answers.each do |answer|
        answer.valid?
        answer.errors.each do |attribute, msg|
          s.errors.add(answer.field.id.to_s.to_sym, msg)
        end
      end
      raise ActiveRecord::RecordInvalid, s
    end
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
