class RecentDocumentsBlock < Block

  def self.description
    _('List of recent content')
  end

  settings_items :limit

  def content
    docs =
      if self.limit.nil?
        owner.recent_documents
      else
        owner.recent_documents(self.limit)
      end

    content_tag('h3', _('Recent content'), :class => 'block-title') +
    content_tag('ul', docs.map {|item| content_tag('li', link_to(item.title, item.url))}.join("\n"))

  end

end
