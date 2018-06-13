require_dependency 'article'

class Article

  has_many :paragraph_comments, -> {
    order('created_at ASC')
      .where('paragraph_uuid IS NOT NULL')
  }, class_name: 'Comment', foreign_key: 'source_id', dependent: :destroy

  before_save :comment_paragraph_plugin_parse_html

  def comment_paragraph_plugin_enabled?
    environment.plugin_enabled?(CommentParagraphPlugin) && self.kind_of?(CommentParagraphPlugin::Discussion)
  end

  def cache_key_with_comment_paragraph(params = {}, user = nil, language = 'en')
    cache_key_without_comment_paragraph(params, user, language) + (user.present? ? '-logged_in-': '-not_logged-')
  end

  alias_method :cache_key_without_comment_paragraph, :cache_key
  alias_method :cache_key, :cache_key_with_comment_paragraph

  def comment_paragraph_plugin_paragraph_content(paragraph_uuid)
    doc =  Nokogiri::HTML(body)
    paragraph = doc.css("[data-macro-paragraph_uuid='#{paragraph_uuid}']").first
    paragraph.present? ? paragraph.text : nil
  end

  protected

  def comment_paragraph_plugin_parse_html
    return unless comment_paragraph_plugin_enabled?
    if body && body_changed?
      updated = body_changed? ? body_change[1] : body
      doc =  Nokogiri::HTML(updated)
      (doc.css('li') + doc.css('body > div, body > span, body > p')).each do |paragraph|
        next if (paragraph['class'] == 'is-not-commentable') || paragraph.css("span[id^='data-macro-uuid']").present? || paragraph.content.blank?
        commentable = paragraph.at('span[data-macro-paragraph_uuid^=""]')
        id = commentable.nil? ? nil : commentable['data-macro-paragraph_uuid']
        commentable ||= Nokogiri::XML::Node.new("span", doc)
        commentable['class'] = "macro article_comments paragraph_comment #{paragraph['class']}"
        commentable['data-macro'] = 'comment_paragraph_plugin/allow_comment'
        commentable.remove_attribute('data-macro-paragraph_uuid')
        commentable['id'] = id ? 'data-macro-uuid-' + id : 'data-macro-uuid-' + SecureRandom.uuid
        commentable.inner_html = paragraph.inner_text
        paragraph.inner_html = commentable
      end
      doc_body =  doc.at('body')
      self.body = doc_body.inner_html if doc_body
    end
  end

  def comment_paragraph_plugin_settings
    @comment_paragraph_plugin_settings ||= Noosfero::Plugin::Settings.new(environment, CommentParagraphPlugin)
  end

end
