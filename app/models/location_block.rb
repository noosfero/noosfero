class LocationBlock < Block

  settings_items :zoom, :type => :integer , :default => 4
  settings_items :map_type, :type => :string , :default => 'roadmap'

  def self.description
    _('Location map')
  end

  def help
    _('Shows where the profile is on the material world.')
  end

  def content
    profile = self.owner
    title = self.title
    if profile.lat
      block_title(title) +
      content_tag('div',
      '<img src="http://maps.google.com/staticmap?center=' + profile.lat.to_s() +
      ',' + profile.lng.to_s() + '&zoom=' + zoom.to_s() +
      '&size=205x250&maptype=' + map_type + '&markers=' + profile.lat.to_s() + ',' +
      profile.lng.to_s() + ',green&key=' + GoogleMaps::key(profile.default_hostname) + '&sensor=false"/>',
      :class => 'the-localization-map' )
    else
      content_tag('i', _('This profile has no geographical position registered.'))
    end
  end

end
