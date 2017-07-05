class MailingListPlugin::UnsubscribeAllJob < Struct.new(:person_id)

  def perform
    person = Person.find(person_id)
    settings = Noosfero::Plugin::Settings.new(person.environment, MailingListPlugin)
    client = MailingListPlugin::Client.new(settings)

    person.memberships.no_templates.each do |group|
      client.unsubscribe_person_from_group_list(person, group)
    end
  end

end
