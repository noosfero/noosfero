class RecentDocumentsBlock < Block

  def self.description
    _('List of recent content')
  end

  settings_items :limit

  include ActionController::UrlWriter
  def content
    docs = self.limit.nil? ? owner.recent_documents : owner.recent_documents(self.limit)

    block_title(_('Recent content')) +
    content_tag('ul', docs.map {|item| content_tag('li', link_to(item.title, item.url))}.join("\n"))

  end

  def footer
    profile = self.owner
    lambda do
      link_to _('All content'), :profile => profile.identifier, :controller => 'profile', :action => 'sitemap'
    end
  end

end
