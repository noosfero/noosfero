class Comment < ActiveRecord::Base

  SEARCHABLE_FIELDS = {
    :title => {:label => _('Title'), :weight => 10},
    :name => {:label => _('Name'), :weight => 4},
    :body => {:label => _('Content'), :weight => 2},
  }

  attr_accessible :body, :author, :name, :email, :title, :reply_of_id, :source

  validates_presence_of :body

  belongs_to :source, :counter_cache => true, :polymorphic => true
  alias :article :source
  alias :article= :source=

  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'
  has_many :children, :class_name => 'Comment', :foreign_key => 'reply_of_id', :dependent => :destroy
  belongs_to :reply_of, :class_name => 'Comment', :foreign_key => 'reply_of_id'

  scope :without_reply, :conditions => ['reply_of_id IS NULL']

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

  acts_as_having_settings

  xss_terminate :only => [ :body, :title, :name ], :on => 'validation'

  acts_as_voteable

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
    self.find(:all, :order => 'created_at desc, id desc', :limit => limit)
  end

  def notification_emails
    self.article.profile.notification_emails - [self.author_email || self.email]
  end

  after_create :new_follower
  def new_follower
    if source.kind_of?(Article)
      article.followers += [author_email]
      article.followers -= article.profile.notification_emails
      article.followers.uniq!
      article.save
    end
  end

  after_create :schedule_notification

  def schedule_notification
    Delayed::Job.enqueue CommentHandler.new(self.id, :verify_and_notify)
  end

  delegate :environment, :to => :profile
  delegate :profile, :to => :source, :allow_nil => true

  include Noosfero::Plugin::HotSpot

  include Spammable
  include CacheCounterHelper

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
      notify_by_mail
    end
  end

  def notify_by_mail
    if source.kind_of?(Article) && article.notify_comments?
      if !notification_emails.empty?
        CommentNotifier.notification(self).deliver
      end
      emails = article.followers - [author_email]
      if !emails.empty?
        CommentNotifier.mail_to_followers(self, emails).deliver
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

  def can_be_marked_as_spam_by?(user)
    return if user.nil?
    user == profile || user.has_permission?(:moderate_comments, profile)
  end

  def can_be_updated_by?(user)
    user.present? && user == author
  end

end
