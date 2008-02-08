class Community < Organization

  settings_items :description

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

  # FIXME should't this method be in Profile class?
  #
  # Adds a person as member of this Community (FIXME).
  def add_member(person)
    self.affiliate(person, Profile::Roles.member)
  end

end
