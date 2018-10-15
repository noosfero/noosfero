class Comment < ApplicationRecord

  include Notifiable

  SEARCHABLE_FIELDS = {
    :title => {:label => _('Title'), :weight => 10},
    :name => {:label => _('Name'), :weight => 4},
    :body => {:label => _('Content'), :weight => 2},
  }

  attr_accessible :body, :author, :name, :email, :title, :reply_of_id, :source, :follow_article

  validates_presence_of :body

  belongs_to :source, :counter_cache => true, :polymorphic => true
  alias :article :source
  alias :article= :source=
  attr_accessor :follow_article

  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'
  has_many :children, :class_name => 'Comment', :foreign_key => 'reply_of_id', :dependent => :destroy
  belongs_to :reply_of, :class_name => 'Comment', :foreign_key => 'reply_of_id'

  scope :without_reply, -> { where 'reply_of_id IS NULL' }

  include TimeScopes

  # unauthenticated authors:
  validates_presence_of :name, :if => (lambda { |record| !record.email.blank? })
  validates_presence_of :email, :if => (lambda { |record| !record.name.blank? })
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| !record.email.blank? })

  # require either a recognized author or an external person
  validates_presence_of :author_id, :if => (lambda { |rec| rec.name.blank? && rec.email.blank? })
  validates_each :name do |rec,attribute,value|
    if rec.author_id && (!rec.name.blank? || !rec.email.blank?)
      rec.errors.add(:name, _('{fn} can only be informed for unauthenticated authors').fix_i18n)
    end
  end

  validate :article_archived?

  store_accessor :metadata
  include MetadataScopes

  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings

  xss_terminate :only => [ :body, :title, :name ], :on => 'validation'

  acts_as_voteable

  will_notify :new_comment_for_author, push: true
  will_notify :new_comment_for_followers, push: true

  def comment_root
    (reply_of && reply_of.comment_root) || self
  end

  def action_tracker_target
    self.article.profile
  end

  def author_name
    if author
      author.short_name
    else
      author_id ? '' : name
    end
  end

  def author_email
    author ? author.email : email
  end

  def author_link
    author ? author.url : email
  end

  def author_url
    author ? author.url : nil
  end

  #FIXME make this test
  def author_custom_image(size = :icon)
    author ? author.profile_custom_image(size) : nil
  end

  def url
    article.view_url.merge(:anchor => anchor)
  end

  def message
    author_id ? _('(removed user)') : _('(unauthenticated user)')
  end

  def removed_user_image
    '/images/icons-app/person-minor.png'
  end

  def anchor
    "comment-#{id}"
  end

  def self.recent(limit = nil)
    self.order('created_at desc, id desc').limit(limit).all
  end

  def notification_emails
    self.article.profile.notification_emails - [self.author_email || self.email]
  end

  after_create :new_follower
  def new_follower
    if source.kind_of?(Article) and !author.nil? and @follow_article
      article.person_followers += [author]
      article.person_followers.uniq!
      article.save
    end
  end

  after_create :schedule_notification

  def schedule_notification
    Delayed::Job.enqueue CommentHandler.new(self.id, :verify_and_notify)
  end

  delegate :environment, :to => :profile

  def environment
    profile && profile.respond_to?(:environment) ? profile.environment : nil
  end

  def profile
    return unless source
    source.kind_of?(Profile) ? source : source.profile
  end

  include Noosfero::Plugin::HotSpot

  include Spammable
  include CacheCounter

  def after_spam!
    SpammerLogger.log(ip_address, self)
    Delayed::Job.enqueue(CommentHandler.new(self.id, :marked_as_spam))
    update_cache_counter(:spam_comments_count, source, 1) if source.kind_of?(Article)
  end

  def after_ham!
    Delayed::Job.enqueue(CommentHandler.new(self.id, :marked_as_ham))
    update_cache_counter(:spam_comments_count, source, -1) if source.kind_of?(Article)
  end

  def verify_and_notify
    check_for_spam
    unless spam?
      send_notifications
    end
  end

  def send_notifications
    if source.kind_of?(Article) && article.notify_comments?
      if !notification_emails.empty?
        notify(:new_comment_for_author, self)
      end
      emails = article.person_followers_email_list - [author_email]
      if !emails.empty?
        notify(:new_comment_for_followers, self, emails)
      end
    end
  end

  after_create do |comment|
    if comment.source.kind_of?(Article)
      comment.article.create_activity if comment.article.activity.nil?
      if comment.article.activity
        comment.article.activity.increment!(:comments_count)
        comment.article.activity.update_attribute(:visible, true)
      end
    end
  end

  after_destroy do |comment|
    comment.article.activity.decrement!(:comments_count) if comment.source.kind_of?(Article) && comment.article.activity
  end

  def replies
    @replies || children
  end

  def replies=(comments_list)
    @replies = comments_list
  end

  include ApplicationHelper
  def reported_version(options = {})
    comment = self
    lambda { render_to_string(:partial => 'shared/reported_versions/comment', :locals => {:comment => comment}) }
  end

  def to_html(option={})
    body || ''
  end

  def rejected?
    @rejected
  end

  def reject!
    @rejected = true
  end

  def need_moderation?
    article.moderate_comments? && (author.nil? || article.author != author)
  end

  def can_be_destroyed_by?(user)
    return if user.nil?
    user == author || user == profile || user.has_permission?(:moderate_comments, profile)
  end

  # method used by the API
  alias_method :allow_destroy?, :can_be_destroyed_by?

  def can_be_marked_as_spam_by?(user)
    return if user.nil?
    user == profile || user.has_permission?(:moderate_comments, profile)
  end

  def can_be_updated_by?(user)
    user.present? && user == author
  end

  def archived?
    self.source && self.source.is_a?(Article) && self.source.archived?
  end

  def new_comment_for_author_notification
    author = self.article.profile
    if author.respond_to? :push_subscriptions
      new_comment_for_followers_notification.merge({
        recipients: [author]
      })
    end
  end
  protected

  def article_archived?
    errors.add(:article, N_('associated with this comment is archived!')) if archived?
  end


  def new_comment_for_followers_notification
    {
      title: self.article.name,
      body: _('%s published a comment.') % self.author.name,
      recipients: self.article.person_followers
    }
  end

end
