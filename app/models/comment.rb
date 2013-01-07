class Comment < ActiveRecord::Base

  validates_presence_of :body

  belongs_to :source, :counter_cache => true, :polymorphic => true
  alias :article :source
  alias :article= :source=

  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'
  has_many :children, :class_name => 'Comment', :foreign_key => 'reply_of_id', :dependent => :destroy
  belongs_to :reply_of, :class_name => 'Comment', :foreign_key => 'reply_of_id'

  named_scope :without_spam, :conditions => ['spam IS NULL OR spam = ?', false]
  named_scope :spam, :conditions => ['spam = ?', true]

  # unauthenticated authors:
  validates_presence_of :name, :if => (lambda { |record| !record.email.blank? })
  validates_presence_of :email, :if => (lambda { |record| !record.name.blank? })
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| !record.email.blank? })

  # require either a recognized author or an external person
  validates_presence_of :author_id, :if => (lambda { |rec| rec.name.blank? && rec.email.blank? })
  validates_each :name do |rec,attribute,value|
    if rec.author_id && (!rec.name.blank? || !rec.email.blank?)
      rec.errors.add(:name, _('%{fn} can only be informed for unauthenticated authors').fix_i18n)
    end
  end

  xss_terminate :only => [ :body, :title, :name ], :on => 'validation'

  delegate :environment, :to => :source

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

  after_save :notify_article
  after_destroy :notify_article
  def notify_article
    article.comments_updated if article.kind_of?(Article)
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
  delegate :profile, :to => :source

  include Noosfero::Plugin::HotSpot

  def verify_and_notify
    check_for_spam
    unless spam?
      notify_by_mail
    end
  end

  def check_for_spam
    plugins.dispatch(:check_comment_for_spam, self)
  end

  def notify_by_mail
    if source.kind_of?(Article) && article.notify_comments?
      if !notification_emails.empty?
        Comment::Notifier.deliver_mail(self)
      end
      emails = article.followers - [author_email]
      if !emails.empty?
        Comment::Notifier.deliver_mail_to_followers(self, emails)
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

  def self.as_thread
    result = {}
    root = []
    order(:id).each do |c|
      c.replies = []
      result[c.id] ||= c
      if result[c.reply_of_id]
        result[c.reply_of_id].replies << c
      else
        root << c
      end
    end
    root
  end

  include ApplicationHelper
  def reported_version(options = {})
    comment = self
    lambda { render_to_string(:partial => 'shared/reported_versions/comment', :locals => {:comment => comment}) }
  end

  def to_html(option={})
    body || ''
  end

  class Notifier < ActionMailer::Base
    def mail(comment)
      profile = comment.article.profile
      recipients comment.notification_emails
      from "#{profile.environment.name} <#{profile.environment.contact_email}>"
      subject _("[%s] you got a new comment!") % [profile.environment.name]
      body :recipient => profile.nickname || profile.name,
        :sender => comment.author_name,
        :sender_link => comment.author_link,
        :article_title => comment.article.name,
        :comment_url => comment.url,
        :comment_title => comment.title,
        :comment_body => comment.body,
        :environment => profile.environment.name,
        :url => profile.environment.top_url
    end
    def mail_to_followers(comment, emails)
      profile = comment.article.profile
      bcc emails
      from "#{profile.environment.name} <#{profile.environment.contact_email}>"
      subject _("[%s] %s commented on a content of %s") % [profile.environment.name, comment.author_name, profile.short_name]
      body :recipient => profile.nickname || profile.name,
        :sender => comment.author_name,
        :sender_link => comment.author_link,
        :article_title => comment.article.name,
        :comment_url => comment.url,
        :unsubscribe_url => comment.article.view_url.merge({:unfollow => true}),
        :comment_title => comment.title,
        :comment_body => comment.body,
        :environment => profile.environment.name,
        :url => profile.environment.top_url
    end
  end

  def rejected?
    @rejected
  end

  def reject!
    @rejected = true
  end

  def spam?
    !spam.nil? && spam
  end

  def ham?
    !spam.nil? && !spam
  end

  def spam!
    self.spam = true
    self.save!
    SpammerLogger.log(ip_address, self)
    Delayed::Job.enqueue(CommentHandler.new(self.id, :marked_as_spam))
    self
  end

  def ham!
    self.spam = false
    self.save!
    Delayed::Job.enqueue(CommentHandler.new(self.id, :marked_as_ham))
    self
  end

  def marked_as_spam
    plugins.dispatch(:comment_marked_as_spam, self)
  end

  def marked_as_ham
    plugins.dispatch(:comment_marked_as_ham, self)
  end

end
