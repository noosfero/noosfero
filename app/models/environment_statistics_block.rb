class EnvironmentStatisticsBlock < Block

  def self.description
    _('Statistical overview of your environment.')
  end

  def default_title
    _('Statistics for %s') % owner.name
  end

  def content
    users = owner.people.find_all_by_public_profile(true).count
    enterprises = owner.enterprises.find_all_by_public_profile(true).count
    communities = owner.communities.find_all_by_public_profile(true).count

    info = [
      n_('One user', '%{num} users', users) % { :num => users },
      n_('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises },
      n_('One community', '%{num} communities', communities) % { :num => communities },
    ]

    block_title(title) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
