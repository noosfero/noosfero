class InvitationJob < Struct.new(:person, :contacts_to_invite, :message, :profile)
  def perform
    Invitation.invite(person, contacts_to_invite, message, profile)
  end
end
