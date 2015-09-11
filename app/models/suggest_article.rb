class SuggestArticle < Task

  validates_presence_of :target_id
  validates_presence_of :email, :name, :if => Proc.new { |task| task.requestor.blank? }
  validates_associated :article_object

  settings_items :email, :type => String
  settings_items :name, :type => String
  settings_items :ip_address, :type => String
  settings_items :user_agent, :type => String
  settings_items :referrer, :type => String
  settings_items :article, :type => Hash, :default => {}

  after_create :schedule_spam_checking

  def schedule_spam_checking
    self.delay.check_for_spam
  end

  include Noosfero::Plugin::HotSpot

  def sender
    requestor ? "#{requestor.name}" : "#{name} (#{email})"
  end

  def article_object
    if @article_object.nil?
      @article_object = article_type.new(article.merge(target.present? ? {:profile => target} : {}).except(:type))
      if requestor.present?
        @article_object.author = requestor
      else
        @article_object.author_name = name
      end
    end
    @article_object
  end

  def article_type
    if article[:type].present?
      type = article[:type].constantize
      return type if type < Article
    end
    TinyMceArticle
    (article[:type] || 'TinyMceArticle').constantize
  end

  def perform
    article_object.save!
  end

  def title
    _("Article suggestion")
  end

  def article_name
    article[:name]
  end

  def subject
    article_name
  end

  def information
    variables = requestor.blank? ? {:requestor => sender} : {}
    { :message => _('%{requestor} suggested the publication of the article: %{subject}.'),
      :variables => variables }
  end

  def accept_details
    true
  end

  def icon
    result = {:type => :defined_image, :src => '/images/icons-app/article-minor.png', :name => article_name}
  end

  def target_notification_description
    _('%{requestor} suggested the publication of the article: %{article}.') %
    {:requestor => sender, :article => article_name}
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
