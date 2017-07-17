class MailingListPlugin::SubscribeMember < Task

  def self.ongoing_subscription(person, group)
    with_metadata({'group_id' => group.id}).where(:target => person).pending.first
  end

  def self.ongoing_subscription?(person, group)
    ongoing_subscription(person, group).present?
  end

  def group
    Profile.find(metadata['group_id'])
  end

  def title
    _("Mailing list subscription")
  end

  def subject
    _('Group asking member to join the mailing list.')
  end

  def linked_subject
    {:text => group.name, :url => group.public_profile_url}
  end

  def information
    {:message => _("%{requestor} wants to subscribe you to %{linked_subject} mailing list.").html_safe }
  end

  def icon
    {:type => :profile_image, :profile => group, :url => group.url}
  end

  def target_notification_message
    _('%{requestor} wants to subscribe you on %{group}\'s mailing list.') % { :requestor => requestor.name, :group => group.name }
  end
  alias :target_notification_description :target_notification_message

  def perform
    environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    client = MailingListPlugin::Client.new(environment_settings)
    client.subscribe_person_on_group_list(target, group)
  end
end
