# FIXME needed by test/units/application_helper.rb
require_dependency 'application_helper'

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

  def notify_from
    @person.last_notification || DateTime.now - @person.notification_time.hours
  end

  def notify
    if @person.notification_time && @person.notification_time > 0
      notifications = @person.tracked_notifications.where("created_at > ?", notify_from)
      tasks = Task.to(@person).without_spam.pending.where("created_at > ?", notify_from).order_by('created_at', 'asc')

      if @person.valid?
        Noosfero.with_locale @person.environment.default_language do
          unless notifications.empty? && tasks.empty?
            Mailer::content_summary(@person, notifications, tasks).deliver
          end
        end
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

  end

  class Mailer < ApplicationMailer

    helper ActionTrackerHelper
    helper do
      def render_activity(activity)
        begin
          render activity.verb, activity: activity
        rescue => error
          Delayed::Worker.logger.warn "PersonNotifier::NotifyJob: Cannot "\
                                      "render template for #{activity.verb} "\
                                      "notification: #{error}"
        end
      end
    end

    def session
      {:user_theme => nil}
    end

    def content_summary(person, notifications, tasks)
      if person.environment
        ApplicationMailer.asset_host = person.environment.top_url
        ApplicationMailer.default_url_options[:host] = person.environment.default_hostname
      end

      @current_theme = 'default'
      @profile = person
      @recipient = @profile.nickname || @profile.name
      @notifications = notifications
      @tasks = tasks
      @environment = @profile.environment
      @url = @profile.environment.top_url
      mail(
        content_type: "text/html",
        from: "#{@profile.environment.name} <#{@profile.environment.noreply_email}>",
        to: @profile.email,
        subject: _("[%s] Notifications") % [@profile.environment.name]
      )
    end
  end
end
