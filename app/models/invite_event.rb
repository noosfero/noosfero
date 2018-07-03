class InviteEvent < Task

  validates :requestor, :kind_of => { :kind => Person }
  validates :target, :kind_of => { :kind => Person }
  validates_presence_of :requestor_id, :target_id
  validate :valid_invitation?, :on => :create

  scope :invitations, -> event { where "metadata ->> 'event_id'= '?'",
                                 event  if event }

  scope :unconfirmed, -> event { where "metadata ->> 'event_id'= '?' AND status = ?",
                                 event, Task::Status::ACTIVE  if event }

  after_create :open_invitation

  def valid_invitation?
    invitation = EventInvitation.new(:event => event, :guest => target,
                   :requestor => requestor,
                   :decision => EventInvitation::DECISIONS['unconfirmed'])

    unless invitation.valid?
      errors.add(:metadata, 'invitation is invalid')
    end
  end

  def event
    Event.find(metadata['event_id']) if metadata['event_id']
  end

  def event= event
    metadata['event_id'] = event.id
  end

  def message
   metadata['message'] if metadata.has_key?('message')
  end

  def message= message
    metadata['message'] = message
  end

  def decision
    metadata['decision'] if metadata.has_key?('decision')
  end

  def decision= decision
    metadata['decision'] = decision
  end

  def invitation
    EventInvitation.find(metadata['invitation_id']) if metadata['invitation_id']
  end

  def invitation= invitation
    metadata['invitation_id'] = invitation.id
  end

  def open_invitation
    invite = EventInvitation.create!(:event => event, :guest => target,
                            :requestor => requestor,
                            :decision => EventInvitation::DECISIONS['unconfirmed'])
    self.invitation = invite
    self.save!
  end

  def perform
    unless self.decision.nil?
      self.invitation.update!(:decision => decision)
    end
  end

  def target_notification_description
    _('%{requestor} invited you to an event.') % {:requestor => requestor.name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You need to login to %{system} to confirm your presence in an event.') %
    { :system => target.environment.name}
  end

  def title
    _("Event Invitation")
  end

  def information
    {:message => _('%{requestor} invited you to an event.') }
  end

  def accept_details
    true
  end

  def custom_action_bar
    true
  end

  def reject_disabled?
    true
  end
end
