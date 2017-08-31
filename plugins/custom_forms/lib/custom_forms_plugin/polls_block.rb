class CustomFormsPlugin::PollsBlock < Block

  attr_accessible :metadata

  def default_title
    _('Polls')
  end

  def self.description
    _('Polls list in profile')
  end

  def self.pretty_name
    _('Polls')
  end

  def type
    'poll'
  end

  def help
    _('This block show last polls performed in profile.')
  end

  include CustomFormsPlugin::ListBlock

end
