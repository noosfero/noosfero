class EnterprisesBlock < ProfileListBlock

  def default_title
    n__('{#} enterprise', '{#} enterprises', profile_count)
  end

  def help
    __('This block displays the enterprises where this user works.')
  end

  def self.description
    __('Enterprises')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to s_('enterprises|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      lambda do
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
