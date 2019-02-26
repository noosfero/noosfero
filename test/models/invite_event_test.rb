require_relative "../test_helper"

class InviteEventTest < ActiveSupport::TestCase

  def setup
    ActiveSupport::TestCase::setup
    @requestor = fast_create(Person)
    @target = fast_create(Person)
    @event = fast_create(Event)
  end

  attr_reader :target, :requestor, :event

  should 'create invite event task' do
    assert_difference "InviteEvent.count", 1 do
      InviteEvent.create(target: target, requestor: requestor,
                         event: event)
    end
  end

  should 'don\'t create invite event task if target isn\'t Person' do
    another_target = fast_create(Organization)
    InviteEvent.any_instance.expects(:valid_invitation?).returns(true)
    invite = InviteEvent.create(target: another_target,
                                requestor: requestor, event: event)
    assert invite.errors[:target].present?
  end

  should 'don\'t create invite event task if requestor isn\'t Person' do
    another_requestor = fast_create(Organization)
    InviteEvent.any_instance.expects(:valid_invitation?).returns(true)
    invite = InviteEvent.create(target: target,
                                requestor: another_requestor, event: event)
    assert invite.errors[:requestor].present?
  end

  should 'don\'t create invite event task if requestor is blank' do
    invite = InviteEvent.create(target: target, event: event)
    assert invite.errors[:requestor].present?
  end

  should 'don\'t create invite event task if target is blank' do
    invite = InviteEvent.create(requestor: requestor, event: event)
    assert invite.errors[:target].present?
  end

  should 'don\'t create invite event task if event is blank' do
    invite = InviteEvent.create(target: target, requestor: requestor)
    assert invite.errors[:metadata].present?
  end

  should 'create invite event task if event has not happened yet' do
    assert_difference "InviteEvent.count", 1 do
      event.start_date = DateTime.now + 2.days
      event.end_date = DateTime.now + 5.days
      event.profile = requestor
      event.save!

      invite = InviteEvent.create(target: target, requestor: requestor,
                                  event: event)
    end
  end

  should 'return event to task' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event)
    assert_equal event, invite.event
  end

  should 'set event id to task' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event)
    another_event = fast_create(Event)
    invite.event = another_event
    assert_equal another_event, invite.event
  end

  should 'return message to invite' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event, message: 'Let\'s go!')
    assert_equal 'Let\'s go!', invite.message
  end

  should 'return decision to invitation' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event, decision: '0')
    assert_equal '0', invite.decision
  end

  should 'return all InviteEvent to event' do
    another_event = fast_create(Event)
    assert_difference "InviteEvent.count", 5 do
      InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: event)

      InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: event)

      InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: event)

      InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: another_event)

      InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: another_event)
    end

    assert InviteEvent.invitations(event).count, 3
    assert InviteEvent.invitations(another_event).count, 2
  end

  should 'return unconfirmed invitaions to event' do
    invitation_1 = InviteEvent.create!(target: fast_create(Person),
                                      requestor: requestor, event: event)

    invitation_2 = InviteEvent.create!(target: fast_create(Person),
                                      requestor: requestor, event: event)

    invitation_3 = InviteEvent.create!(target: fast_create(Person),
                          requestor: requestor, event: event)


    invitation_1.finish

    assert_equal 2, InviteEvent.unconfirmed(event).count
  end

  should 'create EventInvitation after submit task to invte' do
    assert_difference "EventInvitation.count", 1 do
      InviteEvent.create!(target: target, requestor: requestor,
                          event: event)
    end
  end

  should 'create EventInvitation after submit task to invte with \
          unconfirmed decision' do
    InviteEvent.create!(target: target, requestor: requestor,
                        event: event)
    assert_equal EventInvitation::DECISIONS['unconfirmed'], 
            EventInvitation.last.decision
  end

  should 'return invitation to task' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event)
    assert_equal EventInvitation.last, invite.invitation
  end

  should 'update decision when peform task' do
    invite = InviteEvent.create(target: target, requestor: requestor,
                                event: event)

    assert_equal EventInvitation::DECISIONS['unconfirmed'],
            invite.invitation.decision

    invite.decision = EventInvitation::DECISIONS['no']
    invite.finish

    assert_equal EventInvitation::DECISIONS['no'],
            invite.invitation.decision

  end
end
