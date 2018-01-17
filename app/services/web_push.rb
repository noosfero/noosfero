class WebPush

  def self.notify_users(recipients, msg)
    recipients.each do |recipient|
      recipient.push_subscriptions.each{ |s| notify(s, msg) }
    end
  end

  def self.notify(subscription, message)
    begin
      ::Webpush.payload_send(
        endpoint: subscription.endpoint,
        message: message.to_json,
        p256dh: subscription.keys['p256dh'],
        auth: subscription.keys['auth'],
        vapid: {
          subject: subscription.subject,
          public_key: VAPID_KEYS['public_key'],
          private_key: VAPID_KEYS['private_key'],
          expiration: 20.hours
        }
      )
    rescue Webpush::InvalidSubscription
      subscription.destroy
    end
  end

end
