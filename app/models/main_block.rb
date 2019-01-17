class MainBlock < Block

  validate :cannot_be_unacessible

  def self.description
    _('Main content')
  end

  def help
    _('This block presents the main content of your pages.')
  end

  def main?
    true
  end

  def self.pretty_name
    _('Main Content')
  end

  def cacheable?
    false
  end

  def display_options_available
    ['always', 'except_home_page']
  end

  def display_user_options
    @display_user_options = {
      'all'            => _('All users')
    }
  end

  private
  def cannot_be_unacessible
    if display == 'never'
      self.errors.add(:display, :cannot_hide_block)
    end
  end

end
