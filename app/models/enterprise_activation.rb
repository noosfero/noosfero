class EnterpriseActivation < Task

  class RequestorRequired < Exception; end

  acts_as_having_settings :field => :data
  settings_items :enterprise_id, :integer

  validates_presence_of :enterprise_id

  def enterprise
    Enterprise.find(enterprise_id)
  end

  def enterprise=(ent)
    self.enterprise_id = ent.id
  end

  def perform
    raise EnterpriseActivation::RequestorRequired if requestor.nil?
    self.enterprise.enable(requestor)
  end

  def title
    _("Enterprise activation")
  end

  def linked_subject
    {:text => target.name, :url => target.public_profile_url}
  end

  def information
    {:message => _('%{requestor} wants to activate enterprise %{linked_subject}.')}
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def target_notification_description
    _('%{requestor} wants to activate enterprise %{enterprise}.') % {:requestor => requestor.name, :enterprise => enterprise.name}
  end

end
