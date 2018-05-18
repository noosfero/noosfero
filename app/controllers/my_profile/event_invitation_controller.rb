class EventInvitationController < MyProfileController

  def change_invitation_decision

    if params.has_key?(:invitation)
      invitation = EventInvitation.find(params[:invitation])
      invitation.decision = params[:event_invitation][:decision]
    else
      invitation = EventInvitation.new(event: Event.find(params[:event]),
                                       decision: params[:event_invitation][:decision],
                                       guest: current_person)
    end

    task = InviteEvent.unconfirmed(invitation.event).find_by(target: invitation.guest)
    task.finish if task && task.status == Task::Status::ACTIVE

    if invitation && invitation.save
      respond_to do |format|
        format.js do
          render :json => {
              :render_target => "invitation-#{invitation.id}",
              :html => render_to_string(:partial => 'events/event_invitations',
                                        :locals => { event: invitation.event }),
              :msg => 'ok'
           }
        end
      end
    else
      respond_to do |format|
        format.js do
          render :json => { :render_target => nil,
                            :msg => _('Sorry, we can not record your decision.') }
        end
      end
    end
  end

end
