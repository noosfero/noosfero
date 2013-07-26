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

  def footer
    owner = self.owner
    case owner
    when Profile
      proc do
        link_to s_('enterprises|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      proc do
        link_to s_('enterprises|View all'), :controller => 'search', :action => 'assets', :asset => 'enterprises'
      end
    else
      ''
    end
  end

  def profiles
    owner.enterprises
  end

end
