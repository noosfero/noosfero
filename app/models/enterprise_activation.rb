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

end
