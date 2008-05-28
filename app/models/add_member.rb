class AddMember < Task

  validates_presence_of :requestor_id, :target_id

  alias :person :requestor
  alias :person= :requestor=

  alias :community :target
  alias :community= :target=

  def perform
    target.add_member(requestor)
  end

  # FIXME should send email to community admin?
  def sends_email?
    false
  end

  def description
    _('%s wants to be a member') % requestor.name
  end

end
