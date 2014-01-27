class CustomFormsPlugin::AdmissionSurvey < CustomFormsPlugin::MembershipSurvey

  def perform
    super
    requestor.add_member(target)
  end

  def title
    _("Admission survey")
  end

  def information
    {:message => _('%{requestor} wants you to fill in some information before joining.')}
  end

  def target_notification_message
    _('Before joining %{requestor}, the administrators of this organization
      wants you to fill in some further information.') % {:requestor => requestor.name}
  end

  def target_notification_description
    _('%{requestor} wants you to fill in some further information.') % {:requestor => requestor.name}
  end
end
