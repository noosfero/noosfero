class EnvironmentStatisticsBlock < Block

  def self.description
    _('Statistical overview of your environment.')
  end

  def default_title
    _('Statistics for %s') % owner.name
  end

  def help
    _('This block presents some statistics about your environment.')
  end

  def content
    users = owner.people.visible.count
    enterprises = owner.enterprises.visible.count
    communities = owner.communities.visible.count

    info = [
      n_('One user', '%{num} users', users) % { :num => users },
      n__('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises },
      n__('One community', '%{num} communities', communities) % { :num => communities },
    ]

    block_title(title) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
