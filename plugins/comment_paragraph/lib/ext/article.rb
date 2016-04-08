require_dependency 'article'

class Article

  has_many :paragraph_comments, -> {
    order('created_at ASC')
      .where('paragraph_uuid IS NOT NULL')
  }, class_name: 'Comment', foreign_key: 'source_id', dependent: :destroy

  before_save :comment_paragraph_plugin_parse_html

  settings_items :comment_paragraph_plugin_activate, :type => :boolean, :default => false

  def comment_paragraph_plugin_enabled?
    environment.plugin_enabled?(CommentParagraphPlugin) && self.kind_of?(TextArticle)
  end

  def comment_paragraph_plugin_activated?
    comment_paragraph_plugin_activate && comment_paragraph_plugin_enabled?
  end

  def cache_key_with_comment_paragraph(params = {}, user = nil, language = 'en')
    cache_key_without_comment_paragraph(params, user, language) + (user.present? ? '-logged_in-': '-not_logged-')
  end

  alias_method_chain :cache_key, :comment_paragraph

  def comment_paragraph_plugin_paragraph_content(paragraph_uuid)
    doc =  Nokogiri::HTML(body)
    paragraph = doc.css("[data-macro-paragraph_uuid='#{paragraph_uuid}']").first
    paragraph.present? ? paragraph.text : nil
  end

  protected

  def comment_paragraph_plugin_parse_html
    comment_paragraph_plugin_set_initial_value unless persisted?
    return unless comment_paragraph_plugin_activated?
    if body && (body_changed? || setting_changed?(:comment_paragraph_plugin_activate))
      updated = body_changed? ? body_change[1] : body
      doc =  Nokogiri::HTML(updated)
      (doc.css('li') + doc.css('body > div, body > span, body > p')).each do |paragraph|
        next if paragraph.css('[data-macro="comment_paragraph_plugin/allow_comment"]').present? || paragraph.content.blank?

        commentable = Nokogiri::XML::Node.new("span", doc)
        commentable['class'] = "macro article_comments paragraph_comment #{paragraph['class']}"
        commentable['data-macro'] = 'comment_paragraph_plugin/allow_comment'
        commentable['data-macro-paragraph_uuid'] = SecureRandom.uuid
        commentable.inner_html = paragraph.inner_html
        paragraph.inner_html = commentable
      end
      self.body = doc.at('body').inner_html
    end
  end

  def comment_paragraph_plugin_set_initial_value
    self.comment_paragraph_plugin_activate = comment_paragraph_plugin_enabled? &&
      comment_paragraph_plugin_settings.activation_mode == 'auto'
  end

  def comment_paragraph_plugin_settings
    @comment_paragraph_plugin_settings ||= Noosfero::Plugin::Settings.new(environment, CommentParagraphPlugin)
  end

end
