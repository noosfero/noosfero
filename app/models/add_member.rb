class AddMember < Task

  validates_presence_of :requestor_id, :target_id

  alias :person :requestor
  alias :person= :requestor=

  alias :community :target
  alias :community= :target=
  alias :organization :target
  alias :organization= :target=
  alias :enterprise :target
  alias :enterprise= :target=

  acts_as_having_settings :roles, :field => :data

  def perform
    self.roles ||= [Profile::Roles.member.id]
    target.affiliate(requestor, self.roles.map{|i| Role.find(i)})
  end

  def description
    _('%s wants to be a member') % requestor.name
  end

  def permission
    :manage_memberships
  end

  def target_notification_message
    description + "\n\n" +
    _('You need login to accept this.')
  end

end
