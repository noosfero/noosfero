class ProfileSearchBlock < Block

  def self.description
    _('Display a form to search the profile')
  end

  def self.pretty_name
    _('Profile Search')
  end

  def cacheable?
    false
  end

end
