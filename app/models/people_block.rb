class PeopleBlock < ProfileListBlock

  def default_title
    _('People')
  end

  def help
    _('Clicking a person takes you to his/her homepage')
  end

  def self.description
    _('Random people')
  end

  def profiles
    owner.people
  end

  def footer
    lambda do
      link_to _('View all'), :controller => 'search', :action => 'assets', :asset => 'people'
    end
  end

end
