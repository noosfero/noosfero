class LocationBlock < Block

  attr_accessible :zoom, :map_type

  settings_items :zoom, :type => :integer, :default => 4
  settings_items :map_type, :type => :string, :default => 'roadmap'

  def self.description
    _('Location map')
  end

  def help
    _('Shows where the profile is on the material world.')
  end

end
