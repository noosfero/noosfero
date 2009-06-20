class RecentDocumentsBlock < Block

  def self.description
    _('List of recent content')
  end

  def default_title
    _('Recent content')
  end

  def help
    _('This block lists your recent content.')
  end

  settings_items :limit, :type => :integer, :default => 5

  include ActionController::UrlWriter
  def content
    docs = self.limit.nil? ? owner.recent_documents : owner.recent_documents(self.limit)

    block_title(title) +
    content_tag('ul', docs.map {|item| content_tag('li', link_to(item.title, item.url))}.join("\n"))

  end

  def footer
    return nil unless self.owner.is_a?(Profile)

    profile = self.owner
    lambda do
      link_to _('All content'), :profile => profile.identifier, :controller => 'profile', :action => 'sitemap'
    end
  end

  def timeout
    2.months
  end

end
