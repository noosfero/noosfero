class Comment < ActiveRecord::Base
  
  validates_presence_of :title, :body
  belongs_to :article, :counter_cache => true
  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'

  # unauthenticated authors:
  validates_presence_of :name, :if => (lambda { |record| !record.email.blank? })
  validates_presence_of :email, :if => (lambda { |record| !record.name.blank? })
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| !record.email.blank? })

  # require either a recognized author or an external person
  validates_presence_of :author_id, :if => (lambda { |rec| rec.name.blank? && rec.email.blank? })
  validates_each :name do |rec,attribute,value|
    if rec.author_id && (!rec.name.blank? || !rec.email.blank?)
      rec.errors.add(:name, _('%{fn} can only be informed for unauthenticated authors'))
    end
  end

  xss_terminate :only => [ :body, :title, :name ]

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

  def url
    article.view_url.merge(:anchor => anchor)
  end

  def message
   author_id ? _('(removed user)') : ('<br />' + _('(unauthenticated user)'))
  end

  def removed_user_image
    '/images/icons-app/user_icon_size-minor.png'
  end

  def anchor
    "comment-#{id}"
  end

  def self.recent(limit = nil)
    self.find(:all, :order => 'created_at desc, id desc', :limit => limit)
  end

  after_save :notify_article
  after_destroy :notify_article
  def notify_article
    article.comments_updated
  end

  after_create do |comment|
    if comment.article.notify_comments?
      Comment::Notifier.deliver_mail(comment)
    end
  end

  class Notifier < ActionMailer::Base
    def mail(comment)
      profile = comment.article.profile
      email = profile.notification_emails
      return unless email
      recipients email

      from "#{profile.environment.name} <#{profile.environment.contact_email}>"
      subject _("[%s] you got a new comment!") % [profile.environment.name]
      body :recipient => profile.nickname || profile.name,
        :sender => comment.author_name,
        :sender_link => comment.author_link,
        :article_title => comment.article.name,
        :comment_url => comment.url,
        :environment => profile.environment.name,
        :url => profile.environment.top_url
    end
  end

end
