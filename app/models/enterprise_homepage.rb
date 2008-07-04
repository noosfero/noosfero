class EnterpriseHomepage < Article

  def self.short_description
    _('Enterprise homepage.')
  end

  def self.description
    _('Display the summary of profile.')
  end

  def to_html
    body || ''
  end

end
