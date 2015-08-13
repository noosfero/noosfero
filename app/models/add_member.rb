class AddMember < Task

  validates_presence_of :requestor_id, :target_id

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
    {:message => _("%{requestor} wants to be a member of '%{organization}'."),
     variables: {requestor: requestor.name, organization: organization.name}}
  end

  def accept_details
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def permission
    :manage_memberships
  end

  def target_notification_description
    _("%{requestor} wants to be a member of '%{organization}'.") % {:requestor => requestor.name, :organization => organization.name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You will need login to %{system} in order to accept or reject %{requestor} as a member of %{organization}.') % { :system => target.environment.name, :requestor => requestor.name, :organization => organization.name }
  end

  def remove_from_suggestion_list(task)
    suggestion = task.requestor.profile_suggestions.find_by_suggestion_id task.target.id
    suggestion.disable if suggestion
  end

end
