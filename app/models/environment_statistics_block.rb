class EnvironmentStatisticsBlock < Block

  def self.description
    _('Statistical overview of your environment.')
  end

  def content
    users = owner.people.count
    enterprises = owner.enterprises.count
    communities = owner.communities.count

    info = [
      n_('One user', '%{num} users', users) % { :num => users },
      n_('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises },
      n_('One community', '%{num} communities', communities) % { :num => communities },
    ]

    block_title(_('Statistics for  %s') % owner.name) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
