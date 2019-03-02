require_relative "../test_helper"

class EventInvitationTest < ActiveSupport::TestCase

  def setup
    ActiveSupport::TestCase::setup
    @requestor = fast_create(Person)
    @guest = fast_create(Person)
    @event = fast_create(Event)
  end

  attr_reader :guest, :requestor, :event

  should 'create event invitation' do
    assert_difference "EventInvitation.count", 1 do
      EventInvitation.create!(requestor: requestor, guest: guest,
                              event: event, decision: '0')
    end
  end

  should 'don\'t create event invitation if guest is blank' do
    invitation = EventInvitation.create(requestor: requestor,
                                        event: event, decision: '0')
    assert invitation.errors[:guest].present?
  end

  should 'create event invitation even requestor is blank' do
    assert_difference "EventInvitation.count", 1 do
      EventInvitation.create(guest: guest, event: event, decision: '0')
    end
  end

  should 'don\'t create event invitation if event is blank' do
    invitation = EventInvitation.create(requestor: requestor,
                                        guest: guest, decision: '0')
    assert invitation.errors[:event].present?
  end

  should 'don\'t create event invitation if decision is blank' do
    invitation = EventInvitation.create(requestor: requestor,
                                        event: event, guest: guest)
    assert invitation.errors[:decision].present?
  end

  should 'don\'t create event invitation if decision is invalid' do
    invitation = EventInvitation.create(requestor: requestor, event: event,
                                        guest: guest, decision: '9')
    assert invitation.errors[:decision].present?
  end

  should 'don\'t create event invitation if already invitation to guest in event' do
    assert_difference "EventInvitation.count", 1 do
      invitation = EventInvitation.create(requestor: requestor, event: event,
                                          guest: guest, decision: '0')

      another_invitation = EventInvitation.create(event: event, guest: guest,
                                                  decision: '0')
      assert another_invitation.errors[:guest].present?
    end
  end

  should 'create event invitation even if already invitation to guest in another event' do
    assert_difference "EventInvitation.count", 2 do
      invitation = EventInvitation.create(event: event, guest: guest, decision: '0')

      another_event = fast_create(Event)
      another_invitation = EventInvitation.create(event: another_event, guest: guest,
                                                  decision: '0')
    end
  end

  should 'don\'t create invitation if event has already occurred' do

    event.start_date = DateTime.now - 6.days
    event.end_date = DateTime.now - 5.days
    event.profile = requestor
    event.save!

    invitation = EventInvitation.create(guest: guest, event: event,
                   decision: EventInvitation::DECISIONS['yes'])
    assert invitation.errors[:event].present?
  end

  should 'returns decision humanizable' do
    invitation = EventInvitation.create(event: event, guest: guest, decision: '0')
    assert_equal 'yes', invitation.decision_humanizable
  end

  should 'return invitation to person' do
    event = fast_create(Event)
    guest = fast_create(Person)

    invitation = EventInvitation.create!(guest: guest, event: event,
                              decision: EventInvitation::DECISIONS['yes'])

    assert_equal invitation, EventInvitation.invitation_to(event, guest)
  end

  should 'return nil if there is no invitation for person' do
    event = fast_create(Event)
    guest = fast_create(Person)

    assert_nil EventInvitation.invitation_to(event, guest)
  end

  should 'return confirmed invitations to event' do
    event = fast_create(Event)

    confirmed_1 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['yes'])
    confirmed_2 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['yes'])
    rejected = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['no'])

    invitations = EventInvitation.accepted_invitations event

    assert invitations.include?(confirmed_1)
    assert invitations.include?(confirmed_2)
    refute invitations.include?(rejected)
  end

  should 'return rejected invitations to event' do
    event = fast_create(Event)

    rejected_1 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['no'])
    rejected_2 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['no'])
    confirmed = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['yes'])

    invitations = EventInvitation.rejected_invitations event

    assert invitations.include?(rejected_1)
    assert invitations.include?(rejected_2)
    refute invitations.include?(confirmed)
  end

  should 'return maybe accepteds invitations to event' do
    event = fast_create(Event)

    maybe_1 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['maybe'])
    maybe_2 = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['maybe'])
    rejected = EventInvitation.create!(guest: fast_create(Person),
                   event: event, decision: EventInvitation::DECISIONS['no'])

    invitations = EventInvitation.maybe_accept_invitations event

    assert invitations.include?(maybe_1)
    assert invitations.include?(maybe_2)
    refute invitations.include?(rejected)
  end
end
