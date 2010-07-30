class EnvironmentStatisticsBlock < Block

  def self.description
    _('Environment stastistics')
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

    info = []
    info << (n_('One user', '%{num} users', users) % { :num => users })
    unless owner.enabled?('disable_asset_enterprises')
      info << (n__('One enterprise', '%{num} enterprises', enterprises) % { :num => enterprises })
    end
    info << (n__('One community', '%{num} communities', communities) % { :num => communities })

    block_title(title) + content_tag('ul', info.map {|item| content_tag('li', item) }.join("\n"))
  end

end
