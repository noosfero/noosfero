class EnterprisesBlock < ProfileListBlock

  def default_title
    n_('{#} enterprise', '{#} enterprises', profile_count)
  end

  def help
    _('This block displays the enterprises where this user works.')
  end

  def self.description
    _('Enterprises')
  end

  def profiles
    owner.enterprises
  end

end
