class EnterprisesBlock < ProfileListBlock

  def default_title
    _('{#} Enterprises')
  end

  def help
    _('This block displays the enterprises where this user works.')
  end

  def self.description
    _('Enterprises')
  end

  def base_profiles
    owner.enterprises
  end

  private

  def base_class
    Enterprise
  end

end
