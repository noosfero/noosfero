class MainBlock < Block

  def self.description
    _('Block for main content (i.e. your articles, photos, etc)')
  end

  def content
    nil
  end

  def main?
    true
  end

end
