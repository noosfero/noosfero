class InvitationJob < Struct.new(:person_id, :contacts_to_invite, :message, :profile_id, :contact_list_id)
  def perform
    begin
     person = Person.find(person_id)
     profile = Profile.find(profile_id)
     Invitation.invite(person, contacts_to_invite, message, profile)
     ContactList.find(contact_list_id).destroy
    rescue ActiveRecord::NotFound => e
      #...
    end
  end
end
