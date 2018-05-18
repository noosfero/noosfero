class EventInvitation < ApplicationRecord

  belongs_to :event
  belongs_to :guest, :class_name => 'Person'
  belongs_to :requestor, :class_name => 'Person'

  validates_presence_of :event, :guest, :decision
  validates_uniqueness_of :guest, :scope => [:event]
  validate :valid_decision?
  validate :valid_event?, :if => Proc.new { event.present? }

  DECISIONS = { 'yes' => 0,
                'maybe' => 1,
                'no' => 2,
                'unconfirmed' => 3
              }

  scope :accepted_invitations, -> event {
          where "event_id = '?' AND decision = '?'",
          event, EventInvitation::DECISIONS['yes']  if event }

  scope :maybe_accept_invitations, -> event {
          where "event_id = '?' AND decision = '?'",
          event, EventInvitation::DECISIONS['maybe']  if event }

  scope :rejected_invitations, -> event {
          where "event_id = '?' AND decision = '?'",
          event, EventInvitation::DECISIONS['no']  if event }

  scope :unconfirmed_invitations, -> event {
          where "event_id = '?' AND decision = '?'",
          event, EventInvitation::DECISIONS['unconfirmed']  if event }

  scope :invitation_to, -> event, person {
          find_by "event_id = '?' AND guest_id = '?'",
          event, person  if event && person }

  def valid_decision?
    unless EventInvitation::DECISIONS.has_value? decision
      errors.add(:decision, :invalid)
    end
  end

  def valid_event?
    unless event.end_date.nil? || event.end_date >= DateTime.now
      errors.add(:event, 'this event has already happened.')
    end
  end

  def decision_humanizable
    EventInvitation::DECISIONS.key(decision)
  end

end
