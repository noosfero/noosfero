class AddMember < Task

  validates_presence_of :requestor_id, :target_id

  validates :requestor, kind_of: {kind: Person}
  validates :target, kind_of: {kind: Organization}

  alias :person :requestor
  alias :person= :requestor=

  alias :organization :target
  alias :organization= :target=

  settings_items :roles, type: Array

  after_create do |task|
    remove_from_suggestion_list(task)
  end

  def perform
    if !self.roles or (self.roles.uniq.compact.length == 1 and self.roles.uniq.compact.first.to_i.zero?)
      self.roles = [Profile::Roles.member(organization.environment.id).id]
    end
    target.affiliate(requestor, self.roles.select{|r| !r.to_i.zero? }.map{|i| Role.find(i)})
  end

  def title
    _("New member")
  end

  def information
    {:message => _("%{requestor} wants to be a member of '%{target}'."),
     variables: {requestor: requestor.name, target: target.name}}
  end

  def accept_details
    true
  end

  def reject_details
    true
  end

  def footer
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def permission
    :manage_memberships
  end

  def target_notification_description
    requestor_email = " (#{requestor.email})" if requestor.may_display_field_to?("email")

    _("%{requestor}%{requestor_email} wants to be a member of '%{organization}'.").html_safe % {:requestor => requestor.name, :requestor_email => requestor_email, :organization => organization.name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You will need login to %{system} in order to accept or reject %{requestor} as a member of %{organization}.') % { :system => target.environment.name, :requestor => requestor.name, :organization => organization.name }
  end

  def remove_from_suggestion_list(task)
    suggestion = task.requestor.profile_suggestions.find_by suggestion_id: task.target.id
    suggestion.disable if suggestion
  end

  def task_finished_message
    _("You have been accepted at \"%{target}\" with the profile \"%{requestor}\"") %
      {:target => self.target.name,
       :requestor => self.requestor.name}
  end

  def task_cancelled_message
    _("Your request to enter community \"%{target}\" with the profile \"%{requestor}\" was not accepted. Please contact any profile admin from %{target} for more information. The following explanation was given: \n\n\"%{explanation}\"") %
    {:target => self.target.name,
     :requestor => self.requestor.name,
     :explanation => self.reject_explanation}
  end
end
