class EnvironmentStatisticsBlock < Block

  def self.description
    _('Statistical overview of your environment.')
  end

  def default_title
    _('Statistics for %s') % owner.name
  end

  def content
    users = owner.people.count(:conditions => { :public_profile => true })
    enterprises = owner.enterprises.count(:conditions => { :public_profile => true })
    communities = owner.communities.count(:conditions => { :public_profile => true })

    info = [
      n_('One user', '%{num} users', users) % { :num => users },
      n_('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises },
      n_('One community', '%{num} communities', communities) % { :num => communities },
    ]

    block_title(title) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
