class OrdersCyclePlugin::Mailer < Noosfero::Plugin::MailerBase

  include OrdersCyclePlugin::TranslationHelper

  helper ApplicationHelper
  helper OrdersCyclePlugin::TranslationHelper

  attr_accessor :environment
  attr_accessor :profile

  def open_cycle profile, cycle, subject, message
    self.environment = profile.environment
    @profile = profile
    @cycle = cycle
    @message = message

    mail bcc: organization_members(@profile),
      from: environment.noreply_email,
      reply_to: profile_recipients(@profile),
      subject: t('lib.mailer.profile_subject') % {profile: profile.name, subject: subject}
  end

  protected

  def profile_recipients profile
    if profile.person?
      profile.contact_email
    else
      profile.admins.map{ |p| p.contact_email }
    end
  end

  def organization_members profile
    if profile.organization?
      profile.members.map{ |p| p.contact_email }
    end
  end

end
