class MailingListPlugin::AcceptSubscription < Task

  alias :group :target

  def self.ongoing_subscription(person, group)
    with_metadata({'person_id' => person.id}).where(:target => group).pending.first
  end

  def self.ongoing_subscription?(person, group)
    ongoing_subscription(person,group).present?
  end

  def person
    Person.find(metadata['person_id'])
  end

  def title
    _("Mailing list subscription")
  end

  def subject
    _('Member asking to join the group mailing list.')
  end

  def linked_subject
    {:text => person.name, :url => person.public_profile_url}
  end

  def information
    {:message => _("%{linked_subject} wants to subscribe to the mailing list.") }
  end

  def icon
    {:type => :profile_image, :profile => person, :url => person.url}
  end

  def target_notification_message
    _('%{person} wants to subscribe to %{group}\'s mailing list.') % { :person => person.name, :group => group.name }
  end
  alias :target_notification_description :target_notification_message

  def perform
    environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    client = MailingListPlugin::Client.new(environment_settings)
    client.subscribe_person_on_group_list(person, group)
  end
end
