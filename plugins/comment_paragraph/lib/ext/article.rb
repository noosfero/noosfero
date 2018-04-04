require_dependency 'article'

class Article
  has_many :paragraph_comments, -> {
    order('created_at ASC')
      .where('paragraph_uuid IS NOT NULL')
  }, class_name: 'Comment', foreign_key: 'source_id', dependent: :destroy

  after_save :remove_zombie_comments, if: -> (a) { a.body_changed? }

  def comment_paragraph_plugin_enabled?
    environment.plugin_enabled?(CommentParagraphPlugin) && (self.kind_of?(TextArticle) || self.kind_of?(CommentParagraphPlugin::Discussion))
  end

  def cache_key_with_comment_paragraph(params = {}, user = nil, language = 'en')
    cache_key_without_comment_paragraph(params, user, language) + (user.present? ? '-logged_in-': '-not_logged-')
  end

  alias_method_chain :cache_key, :comment_paragraph

  def comment_paragraph_plugin_paragraph_content(paragraph_uuid)
    doc = Nokogiri::HTML(body)
    paragraph = doc.css("[data-macro-paragraph_uuid='#{paragraph_uuid}']").first
    paragraph.present? ? paragraph.text : nil
  end

  private

  def remove_zombie_comments
    uuids = Nokogiri::HTML(body).css('div.macro')
                                .map { |p| p['data-macro-paragraph_uuid'] }
    paragraph_comments.where('paragraph_uuid NOT IN (?)', uuids).destroy_all
  end
end
