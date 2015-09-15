class NewsletterPlugin < Noosfero::Plugin

  def self.plugin_name
    "Newsletter"
  end

  def self.plugin_description
    _("Periodically sends newsletter via email to network users")
  end

  def js_files
    'newsletter_plugin.js'
  end

  def stylesheet?
    true
  end

  def self.compile_and_send_newsletters
    NewsletterPlugin::Newsletter.enabled.each do |newsletter|
      if newsletter.must_be_sent_today? && newsletter.has_posts_in_the_period?
        if newsletter.moderated
          NewsletterPlugin::ModerateNewsletter.create!(
            :newsletter_id => newsletter.id,
            :environment => newsletter.environment
          )
        else
          mailing = NewsletterPlugin::NewsletterMailing.create!(
            :source => newsletter,
            :subject => newsletter.subject,
            :body => newsletter.body,
            :person => newsletter.person,
            :locale => newsletter.environment.default_locale,
          )
          mailing.update_attribute(:body, mailing.body.gsub('{mailing_url}', mailing.url))
        end
      end
    end
  end

end
