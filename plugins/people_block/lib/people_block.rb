class PeopleBlock < PeopleBlockBase

  def self.description
    _('People')
  end

  def help
    _('Clicking a person takes you to his/her homepage')
  end

  def default_title
    _('{#} People')
  end

  def profiles
    owner.people
  end

  def footer
    lambda do |context|
      link_to _('View all'), :controller => 'search', :action => 'people'
    end
  end

end
