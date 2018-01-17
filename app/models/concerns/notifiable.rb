module Notifiable
  extend ActiveSupport::Concern

  class UnregisteredVerb      < StandardError; end
  class InvalidPushRecipients < StandardError; end
  class InvalidPushMessage    < StandardError; end

  included do
    def notify(verb, *args)
      unless respond_to?("#{verb}_settings", true)
        raise UnregisteredVerb, "Notification verb not registered"
      end
      notify_by_mail(verb, *args)
      notify_by_push(verb, *args)
      notify_by_plugins(verb, *args)
    end

    private

    def notify_by_mail(verb, *args)
      begin
        settings = self.send("#{verb}_settings")
        mailer = settings[:mailer]
        if mailer.present? && mailer.respond_to?(verb)
          settings[:mailer].send(verb, *args).try(:deliver)
        end
      rescue NotImplementedError => ex
        Rails.logger.info "Error when notifying '#{verb}' by mail: " + ex.to_s
      end
    end

    def notify_by_push(verb, *args)
      settings = self.send("#{verb}_settings")
      if settings[:push] &&
         self.respond_to?("#{verb}_notification", true)
        data = self.send("#{verb}_notification")
        return unless data.present?

        recipients = data.delete(:recipients)
        raise InvalidPushRecipients unless recipients.present?
        raise InvalidPushMessage if data[:title].blank? || data[:body].blank?
        WebPush.notify_users(recipients, data)
      end
    end

    def notify_by_plugins(verb, *args)
      plugins.dispatch(:custom_notification, verb, *args)
    end

    handle_asynchronously :notify_by_mail
    handle_asynchronously :notify_by_push

  end

  class_methods do
    def will_notify(verb, opts={})
      instance_eval do
        define_method "#{verb}_settings" do
          {
            mailer: self.class.mailer_for_class,
            push: false
          }.merge(opts)
        end

        private "#{verb}_settings"
      end
    end

    def mailer_for_class
      begin
        klass = self.respond_to?(:base_class) ? self.base_class : self
        "#{klass.name}Mailer".constantize
      rescue NameError
        nil
      end
    end
  end

end
