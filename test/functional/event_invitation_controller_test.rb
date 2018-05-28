require_relative "../test_helper"

class EventInvitationControllerTest < ActionController::TestCase

  def setup
    super
    @profile = create_user('testinguser')
    @guest = @profile.person
    @event = fast_create(Event)
    login_as :testinguser
  end

  attr_reader :profile, :guest, :event

  should 'create invitation decision to guest' do

    assert_difference 'EventInvitation.count', 1 do

      xhr :post, :change_invitation_decision,
            profile: guest.identifier, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }

    end
  end

  should 'change invitation decision to guest' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    xhr :post, :change_invitation_decision, profile: guest.identifier,
            invitation: invitation, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }

    assert_equal EventInvitation::DECISIONS['yes'], invitation.reload.decision
  end

  should 'close the task if the user has received an invitation and replied \
          by the event page' do

    task = InviteEvent.create!(requestor: fast_create(Person),
                                target: guest, event: event)

    xhr :post, :change_invitation_decision, profile: guest.identifier,
            invitation: task.invitation, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }

    assert_equal Task::Status::FINISHED, task.reload.status
  end

  should 'return error message if don\'t save invitation' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    # Past decision is invalid to fail save
    xhr :post, :change_invitation_decision, profile: guest.identifier,
            invitation: invitation, event: event,
            event_invitation: { decision: '9' }

    assert_nil ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should 'return invitation id in json response' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    xhr :post, :change_invitation_decision, profile: guest.identifier,
            invitation: invitation, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }

    assert_equal "invitation-#{invitation.id}",
      ActiveSupport::JSON.decode(@response.body)['render_target']
  end

end
