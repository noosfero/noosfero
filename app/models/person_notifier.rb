class PersonNotifier

  def initialize(person)
    @person = person
  end

  def self.schedule_all_next_notification_mail
    Delayed::Job.enqueue(NotifyAllJob.new) unless NotifyAllJob.exists?
  end

  def schedule_next_notification_mail
    dispatch_notification_mail if !NotifyJob.exists?(@person.id)
  end

  def dispatch_notification_mail
    Delayed::Job.enqueue(NotifyJob.new(@person.id), {:run_at => @person.notification_time.hours.from_now}) if @person.notification_time>0
  end

  def reschedule_next_notification_mail
    return nil unless @person.setting_changed?(:notification_time) || @person.setting_changed?(:last_notification)
    NotifyJob.find(@person.id).delete_all
    schedule_next_notification_mail
  end

  def notify
    if @person.notification_time && @person.notification_time > 0
      from = @person.last_notification || DateTime.now - @person.notification_time.hours
      notifications = @person.tracked_notifications.find(:all, :conditions => ["created_at > ?", from])
      Noosfero.with_locale @person.environment.default_language do
        Mailer::content_summary(@person, notifications).deliver unless notifications.empty?
      end
      @person.settings[:last_notification] = DateTime.now
      @person.save!
    end
  end

  class NotifyAllJob
    def self.exists?
      Delayed::Job.by_handler("--- !ruby/object:PersonNotifier::NotifyAllJob {}\n").count > 0
    end

    def perform
      Person.find_each {|person| person.notifier.schedule_next_notification_mail }
    end
  end

  class NotifyJob < Struct.new(:person_id)

    def self.exists?(person_id)
      !find(person_id).empty?
    end

    def self.find(person_id)
      Delayed::Job.by_handler("--- !ruby/struct:PersonNotifier::NotifyJob\nperson_id: #{person_id}\n")
    end

    def perform
      Person.find(person_id).notifier.notify
    end

    def failure(job)
      person = Person.find(person_id)
      person.notifier.dispatch_notification_mail
    end

  end

  class Mailer < ActionMailer::Base

    add_template_helper(PersonNotifierHelper)

    def session
      {:theme => nil}
    end

    def content_summary(person, notifications)
      @current_theme = 'default'
      @profile = person
      @recipient = @profile.nickname || @profile.name
      @notifications = notifications
      @environment = @profile.environment.name
      @url = @profile.environment.top_url
      mail(
        content_type: "text/html",
        from: "#{@profile.environment.name} <#{@profile.environment.contact_email}>",
        to: @profile.email,
        subject: _("[%s] Network Activity") % [@profile.environment.name]
      )
    end
  end
end
