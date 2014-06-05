class FansBlock < ProfileListBlock

  def self.description
    _('Displays the people who like the enterprise')
  end

  def default_title
    n_('{#} fan', '{#} fans', profile_count)
  end

  def help
    _('This block presents the fans of an enterprise.')
  end

  def footer
    profile = self.owner
    proc do
      link_to _('View all'), :profile => profile.identifier, :controller =>
      'profile', :action => 'fans'
    end
  end

  def profiles
    owner.fans
  end

  def profile_count
    profiles.visible.count
  end

end
