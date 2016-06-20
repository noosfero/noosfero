class PersonTagsPlugin::InterestsBlock < Block
  def view_title
    self.default_title 
  end

  def tags
    owner.tag_list
  end

  def extra_option
    {}
  end

  def self.description
    _('Fields of Interest')
  end

  def help
    _('Things that this person is interested in')
  end

  def default_title
    _('Fields of Interest')
  end

  def self.expire_on
    { profile: [:profile] }
  end
end
