module Notifiable
  extend ActiveSupport::Concern

  class UnregisteredVerb < StandardError; end

  included do
    def notify(verb, *args)
      unless respond_to?("#{verb}_settings", true)
        raise UnregisteredVerb, "Notification verb not registered"
      end
      notify_by_mail(verb, *args)
      notify_by_push(verb, *args)
    end

    private

    def notify_by_mail(verb, *args)
      settings = self.send("#{verb}_settings")
      mailer = settings[:mailer]
      if mailer.present? && mailer.respond_to?(verb)
        settings[:mailer].send(verb, *args).try(:deliver)
      end
    end

    def notify_by_push(verb, *args)
      settings = self.send("#{verb}_settings")
      if settings[:push] &&
         self.responds_to?("#{verb}_notification")
        # TODO: push
      end
    end

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
