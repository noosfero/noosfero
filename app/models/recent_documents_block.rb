class RecentDocumentsBlock < Block

  def self.description
    _('Display the last content produced in the context where the block is available.')
  end

  def self.short_description
    _('Show last updates')
  end

  def self.pretty_name
    _('Recent Content')
  end

  def default_title
    _('Recent content')
  end

  def help
    _('This block lists your content most recently updated.')
  end

  settings_items :limit, :type => :integer, :default => 5

  def docs
    self.limit.nil? ? owner.recent_documents(nil, {}, false) : owner.recent_documents(self.get_limit, {}, false)
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end
end
