require 'yaml'

class MailingListPlugin::Client
  def initialize(settings)
    @settings = settings
    @client = Mail::Sympa.new(@settings.api_url, @settings.api_url)
    @client.login(@settings.administrator_email, @settings.administrator_password)
  end

  attr_accessor :client, :config

  def list
    client.complex_lists.map {|object| object.listAddress.split('@').first}
  end

  def review(group)
    begin
      subscribers = client.review(treat_identifier(group.identifier))
    rescue SOAP::FaultError
      subscribers = []
    end
    subscribers == ['no_subscribers'] ? [] : subscribers
  end

  def group_list_members(group)
    review(group).map do |email|
      User.find_by_email(email).try(:person)
    end.flatten
  end

  def group_list_exist?(group)
    complex_lists.each do |list|
      return true if list.listAddress =~ /#{treat_identifier(group.identifier)}@/
    end
    return false
  end

  def person_subscribed_on_group_list?(person, group)
    review(group).include?(person.email)
  end

  def treat_identifier(identifier)
    while identifier.size > 50 && identifier =~ /-/
      identifier = identifier.split('-')[0..-2].join('-')
    end

    if identifier.size > 50
      identifier = identifier[0..49]
    end

    identifier
  end

  def create_list_for_group(group)
    create_list(treat_identifier(group.identifier), _('Mailing list of %s') % group.name.transliterate) unless group_list_exist?(group)
    group.members.each do |member|
      subscribe_person_on_group_list(member, group)
    end
  end

  # There is no api for removing a list. The close_list only closes the list
  # and there isn't also an api method for reopening it. So we'll just
  # unsubscribe all the emails.
  def close_list_for_group(group)
    group.members.each do |member|
      unsubscribe_person_from_group_list(member, group)
    end
  end

  def subscribe_person_on_group_list(person, group)
    add(person.email, treat_identifier(group.identifier), person.name) unless !group_list_exist?(group) || person_subscribed_on_group_list?(person, group)
  end

  def unsubscribe_person_from_group_list(person, group)
    del(person.email, treat_identifier(group.identifier)) if group_list_exist?(group) && person_subscribed_on_group_list?(person, group)
  end

  def deploy_list_for_group(group)
    create_list_for_group(group)
    add(@settings.administrator_email, treat_identifier(group.identifier), _('Administrator')) unless review(group).include?(@settings.administrator_email)
  end

  def group_list_email(group)
    "#{treat_identifier(group.identifier)}@#{URI(@settings.api_url).host}"
  end

  def method_missing(m, *args)
    client.send(m, *args)
  end
end
