class SuggestArticle < Task

  validates_presence_of :target_id, :article_name, :email, :name, :article_body

  settings_items :email, :type => String
  settings_items :name, :type => String
  settings_items :article_name, :type => String
  settings_items :article_body, :type => String
  settings_items :article_abstract, :type => String
  settings_items :article_parent_id, :type => String
  settings_items :source, :type => String
  settings_items :source_name, :type => String
  settings_items :highlighted, :type => :boolean, :default => false
  settings_items :ip_address, :type => String
  settings_items :user_agent, :type => String
  settings_items :referrer, :type => String

  after_create :schedule_spam_checking

  def schedule_spam_checking
    self.delay.check_for_spam
  end

  include Noosfero::Plugin::HotSpot

  def sender
    "#{name} (#{email})"
  end

  def perform
    task = TinyMceArticle.new
    task.profile = target
    task.name = article_name
    task.author_name = name
    task.body = article_body
    task.abstract = article_abstract
    task.parent_id = article_parent_id
    task.source = source
    task.source_name = source_name
    task.highlighted = highlighted
    task.save!
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

  def target_notification_description
    _('%{sender} suggested the publication of the article: %{article}.') %
    {:sender => sender, :article => article_name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this article.') % { :system => target.environment.name }
  end

  def after_spam!
    SpammerLogger.log(ip_address, self)
    self.delay.marked_as_spam
  end

  def after_ham!
    self.delay.marked_as_ham
  end
end
