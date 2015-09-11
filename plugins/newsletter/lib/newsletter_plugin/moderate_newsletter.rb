class NewsletterPlugin::ModerateNewsletter < Task

  settings_items :newsletter_id, :post_ids
  validates_presence_of :newsletter_id

  alias :environment :target
  alias :environment= :target=

  def perform
    newsletter = NewsletterPlugin::Newsletter.find(newsletter_id)
    self.post_ids ||= []
    mailing = NewsletterPlugin::NewsletterMailing.create!(
      :source => newsletter,
      :subject => newsletter.subject,
      :body => newsletter.body(:post_ids => self.post_ids.reject{|id| id.to_i.zero?}),
      :person => newsletter.person,
      :locale => newsletter.environment.default_locale,
    )
    mailing.update_attribute(:body, mailing.body.gsub('{mailing_url}', mailing.url))
  end

  def title
    _("Moderate newsletter")
  end

  def subject
    nil
  end

  def linked_subject
    nil
  end

  def information
    {:message => _('You have to moderate a newsletter.') }
  end

  def accept_details
    true
  end

  def icon
    {:type => :defined_image, :src => "/images/control-panel/email.png", :name => 'Newsletter'}
  end

  def target_notification_message
    _('A newsletter was generated and you need to review it before it is sent to users.')
  end

  def target_notification_description
    _('You need to moderate a newsletter.')
  end
end
