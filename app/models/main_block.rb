class MainBlock < Block

  def self.description
    _('Main content')
  end

  def help
    _('This block presents the main content of your pages.')
  end

  def main?
    true
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

end
