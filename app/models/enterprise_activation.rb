class EnterpriseActivation < Task

  alias :person :requestor
  alias :person= :requestor=

  alias :enterprise :target
  alias :enterprise= :target=

  validates_presence_of :enterprise

  validates :target, kind_of: {kind: Enterprise}

  def perform
    self.enterprise.enable self.requestor
  end

  def title
    _("Enterprise activation")
  end

  def linked_subject
    {:text => target.name, :url => target.public_profile_url}
  end

  def information
    if self.requestor
      {:message => _('%{requestor} wants to activate enterprise %{linked_subject}.')}
    else
      {:message => _('Pending activation of enterprise %{linked_subject}.')}
    end
  end

  def icon
    if self.requestor
      {:type => :profile_image, :profile => self.requestor, :url => self.requestor.url}
    else
      {:type => :profile_image, :profile => self.enterprise, :url => self.enterprise.url}
    end
  end

  def target_notification_description
    if self.requestor
      _('%{requestor} wants to activate enterprise %{enterprise}.') % {:requestor => self.requestor.name, :enterprise => self.enterprise.name}
    else
      _('Pending activation of enterprise %{enterprise}.') % {:enterprise => self.enterprise.name}
    end
  end

end
