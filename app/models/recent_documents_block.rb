class RecentDocumentsBlock < Design::Block

  def content
    lambda do
      content_tag(
        'ul',
        profile.recent_documents.map {|item| link_to_document(item) }.join("\n")
      )
    end
  end

end
