class GetEmailContactsJob < Struct.new(:import_from, :login, :password, :contact_list_id)
  def perform
    begin
      Invitation.get_contacts(import_from, login, password, contact_list_id)
    rescue Contacts::AuthenticationError => ex
      ContactList.find(contact_list_id).register_auth_error
    rescue Exception => ex
      ContactList.find(contact_list_id).register_error
    end
  end
end
