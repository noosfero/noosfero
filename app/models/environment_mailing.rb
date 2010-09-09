class EnvironmentMailing < Mailing

  def recipient(offset=0)
    Person.find(:first, :conditions => [ "environment_id = ?", source_id], :order => :id, :offset => offset)
  end

  def each_recipient
    offset = 0
    while person = recipient(offset)
      unless self.already_sent_mailing_to?(person)
        yield person
      end
      offset = offset + 1
    end
  end

  def signature_message
    _('Sent by Noosfero %s.') % source.name
  end

  def url
    source.top_url
  end
end
