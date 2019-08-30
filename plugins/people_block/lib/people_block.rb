class PeopleBlock < PeopleBlockBase
  def self.description
    c_("People")
  end

  def help
    _("Clicking a person takes you to his/her homepage")
  end

  def default_title
    _("{#} People")
  end

  def profiles(user = nil)
    profiles = super
    profiles.activated.order("RANDOM()")
  end
end
