class InterestTagsBlock < Block
  def view_title
    self.default_title
  end

  def tags
    owner.tags
  end

  def extra_option
    {}
  end

  def self.description
    _('Tags of interest')
  end

  def help
    _('Contents that this person is interested in')
  end

  def default_title
    _('Interest Tags')
  end

  def self.expire_on
    { profile: [:profile] }
  end
end
