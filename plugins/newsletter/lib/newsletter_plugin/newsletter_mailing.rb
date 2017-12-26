class NewsletterPlugin::NewsletterMailing < EnvironmentMailing

  attr_accessible :source, :person, :locale

  validates_presence_of :person

  after_create :replace_mailing_url

  def replace_mailing_url
    self.update_attribute(:body, self.body.gsub('%7Bmailing_url%7D', self.url))
  end

  def url
    "#{self.source.top_url}/plugin/newsletter/mailing/#{self.id}"
  end

  def source
    NewsletterPlugin::Newsletter.find(source_id)
  end

  def deliver
    source.additional_recipients.each do |recipient|
      begin
        Mailing::Sender.notification(self, recipient[:email]).deliver
      rescue Exception => ex
        Rails.logger.error("#{ex.class.to_s} - #{ex.to_s} at #{__FILE__}:#{__LINE__}")
      end
    end
    super
  end

end
