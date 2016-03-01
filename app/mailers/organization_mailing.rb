class OrganizationMailing < Mailing

  def generate_from
    "#{person.name} <#{source.environment.noreply_email}>"
  end

  def recipients(offset=0, limit=100)
    result = source.members.order(:id).offset(offset).limit(limit)

    if data.present? and data.is_a?(Hash) and data[:members_filtered]
      result = result.where('profiles.id IN (?)', data[:members_filtered])
    end

    if result.blank?
      result = result.joins("LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)")
      .where("m.person_id" => nil)
    end
    result
  end

  def each_recipient
    offset = 0
    limit = 50
    while !(people = recipients(offset, limit)).empty?
      people.each do |person|
        yield person
      end
      offset = offset + limit
    end
  end

  def signature_message
    _('Sent by community %s.') % source.name
  end

  include Rails.application.routes.url_helpers
  def url
    url_for(source.url)
  end
end
