class OrganizationMailing < Mailing

  def generate_from
    "#{person.name} <#{source.environment.contact_email}>"
  end

  def recipient(offset=0)
    environment_id = source.environment_id
    Person.find(:first, :conditions => ['environment_id = ? and role_assignments.resource_type = ? and role_assignments.resource_id = ?', environment_id, 'Profile', source.id], :include => :role_assignments, :order => "profiles.id", :offset => offset)
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
    _('Sent by community %s.') % source.name
  end

  include ActionController::UrlWriter
  def url
    url_for(source.url)
  end
end
