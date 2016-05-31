class EnvironmentMailing < Mailing

  settings_items :recipients_roles, :type => :array
  attr_accessible :recipients_roles

  def recipients(offset=0, limit=100)
    recipients_by_role.order(:id).offset(offset).limit(limit)
      .joins("LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)")
      .where("m.person_id" => nil)
  end

  def recipients_by_role
    if recipients_roles.blank?
      source.people
    else
      roles = Environment::Role.where("key in (?)", self.recipients_roles)
      Person.by_role(roles).where(environment_id: self.source_id)
    end
  end

  def each_recipient
    offset = 0
    limit = 100
    while !(people = recipients(offset, limit)).empty?
      people.each do |person|
          yield person
      end
      offset = offset + limit
    end
  end

  def signature_message
    _('Sent by %s.') % source.name
  end

  def url
    source.top_url
  end
end
