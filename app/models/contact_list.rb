class ContactList < ApplicationRecord

  serialize :list, Array

  def list
    self[:list] || []
  end

  def data
    if self.fetched
      { "fetched" => true, "contact_list" => self.id, "error" => self.error_fetching }
    else
      {}
    end
  end

  def register_auth_error
    msg = _('There was an error while authenticating. Did you enter correct login and password?')
    self.fetched = true
    self.error_fetching = msg
    self.save!
  end

  def register_error
    msg = _('There was an error while looking for your contact list. Please, try again')
    self.fetched = true
    self.error_fetching = msg
    self.save!
  end

end
