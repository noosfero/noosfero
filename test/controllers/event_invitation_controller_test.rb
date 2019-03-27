require_relative "../test_helper"

class EventInvitationControllerTest < ActionDispatch::IntegrationTest

  def setup
    super
    @profile = create_user('testinguser')
    @guest = @profile.person
    @event = fast_create(Event)
    login_as_rails5 :testinguser
  end

  attr_reader :profile, :guest, :event

  should 'create invitation decision to guest' do

    assert_difference 'EventInvitation.count', 1 do

      post change_invitation_decision_event_invitation_index_path(guest.identifier), params: {
	      event: event.id,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }}, xhr: true

    end
  end

  should 'change invitation decision to guest' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    post change_invitation_decision_event_invitation_index_path(guest.identifier), params: {
	    invitation: invitation.id, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }}, xhr: true

    assert_equal EventInvitation::DECISIONS['yes'], invitation.reload.decision
  end

  should 'close the task if the user has received an invitation and replied \
          by the event page' do

    task = InviteEvent.create!(requestor: fast_create(Person),
                                target: guest, event: event)

    post change_invitation_decision_event_invitation_index_path(guest.identifier), params: {
	    invitation: task.invitation.id, event: event,
	    event_invitation: { decision: EventInvitation::DECISIONS['yes'] }}, xhr: true

    assert_equal Task::Status::FINISHED, task.reload.status
  end

  should 'return error message if don\'t save invitation' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    # Past decision is invalid to fail save
    post change_invitation_decision_event_invitation_index_path(guest.identifier), params: {
	    invitation: invitation.id, event: event,
            event_invitation: { decision: '9' }}, xhr: true

    assert_nil ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should 'return invitation id in json response' do

    invitation = EventInvitation.create(guest: guest, event: event,
                  decision: EventInvitation::DECISIONS['unconfirmed'])

    post change_invitation_decision_event_invitation_index_path(guest.identifier), params: {
	    invitation: invitation.id, event: event,
            event_invitation: { decision: EventInvitation::DECISIONS['yes'] }}, xhr: true

    assert_equal "invitation-#{invitation.id}",
      ActiveSupport::JSON.decode(@response.body)['render_target']
  end

end
