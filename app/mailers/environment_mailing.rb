class EnvironmentMailing < Mailing

  def recipients(offset=0, limit=100)
    source.people.order(:id).offset(offset).limit(limit)
      .joins("LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)")
      .where("m.person_id" => nil)
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
