class AddMember < Task

  validates_presence_of :requestor_id, :target_id

  alias :person :requestor
  alias :person= :requestor=

  alias :organization :target
  alias :organization= :target=

  acts_as_having_settings :roles, :field => :data

  def perform
    self.roles ||= [Profile::Roles.member.id]
    target.affiliate(requestor, self.roles.map{|i| Role.find(i)})
  end

  def description
    _('%s wants to be a member of "%s".') % [requestor.name, organization.name]
  end

  def permission
    :manage_memberships
  end

  def target_notification_message
    description + "\n\n" +
    _('You will need login to %{system} in order to accept or reject %{requestor} as a member of %{organization}.') % { :system => target.environment.name, :requestor => requestor.name, :organization => organization.name }
  end

end
