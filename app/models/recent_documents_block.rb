class RecentDocumentsBlock < Block

  def content
    lambda do
      content_tag(
        'ul',
        profile.recent_documents.map {|item| content_tag('li', link_to_document(item)) }.join("\n")
      )
    end
  end

end
