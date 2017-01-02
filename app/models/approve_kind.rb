class ApproveKind < Task
  validates_presence_of :requestor_id, :target_id

  def kind
    Kind.find_by id: data[:kind_id]
  end

  def kind= kind
    data[:kind_id] = kind.id
  end

  def perform
    requestor.kinds << kind
  end

  def title
    _("Kind definition")
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def task_message
    _('%{requestor} wants to be defined as "%{kind}".') % {:kind => kind.name, :requestor => requestor.name}
  end

  def information
    {:message => task_message}
  end

  def reject_details
    true
  end

  def target_notification_description
    task_message
  end

  def task_created_message
    _('Your request to be defined as "%s" was created and is being reviewed by the administrators.') % kind.name
  end

  def task_finished_message
    _('Your request to be defined as "%s" was approved.') % kind.name
  end

  def task_cancelled_message
    message = _('Your request to be defined as "%s" was rejected.') % kind.name
    if !reject_explanation.blank?
      message += " " + _("Here is the reject explanation left by the administrator who rejected your request: \n\n%{reject_explanation}") % {:reject_explanation => reject_explanation}
    end
    message
  end
end
