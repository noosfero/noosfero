class ProfileSearchBlock < Block

  def self.description
    _('Display a form to search the profile')
  end

  def cacheable?
    false
  end

end
