class MainBlock < Block

  def self.description
    _('Main content')
  end

  def help
    _('This block presents the main content of your pages.')
  end

  def content
    nil
  end

  def main?
    true
  end

  def editable?
    false
  end

  def cacheable?
   false
  end

end
