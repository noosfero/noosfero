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

  def base_profiles
    owner.fans
  end

  def self.pretty_name
      _('Fans')
  end

  private

  def base_class
    Person
  end

end
