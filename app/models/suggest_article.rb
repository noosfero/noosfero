class SuggestArticle < Task

  has_captcha  

  serialize :data, Hash
  acts_as_having_settings :field => :data

  validates_presence_of :target_id, :article_name, :email, :name, :article_body

  settings_items :email, :type => String
  settings_items :name, :type => String
  settings_items :article_name, :type => String
  settings_items :article_body, :type => String
  settings_items :article_abstract, :type => String
  settings_items :article_parent_id, :type => String
  settings_items :source, :type => String
  settings_items :source_name, :type => String
  settings_items :highlighted, :type => :boolean

  def sender
    "#{name} (#{email})"
  end

  def perform
    TinyMceArticle.create!(
      :profile => target,
      :name => article_name,
      :author_name => name,
      :body => article_body,
      :abstract => article_abstract,
      :parent_id => article_parent_id,
      :source => source,
      :source_name => source_name,
      :highlighted => highlighted
    )
  end

  def title
    _("Article suggestion")
  end

  def subject
    article_name
  end

  def information
    { :message => _('%{sender} suggested the publication of the article: %{subject}.'),
      :variables => {:sender => sender} }
  end

  def accept_details
    true
  end

  def icon
    result = {:type => :defined_image, :src => '/images/icons-app/article-minor.png', :name => article_name}
  end

  def target_notification_message
    _('%{sender} suggested the publication of the article: %{article}.') %
    {:sender => sender, :article => article_name} + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this article.') % { :system => target.environment.name }
  end

end
