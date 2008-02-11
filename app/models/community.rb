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

  after_create :create_default_set_of_blocks_for_community
  def create_default_set_of_blocks_for_community
    # "main" area
    # nothing ...
    
    # "left" area
    self.boxes[1].blocks << ProfileInfoBlock.new
    self.boxes[1].blocks << RecentDocumentsBlock.new

    # "right" area
    self.boxes[2].blocks << MembersBlock.new
    self.boxes[2].blocks << TagsBlock.new
  end

end
