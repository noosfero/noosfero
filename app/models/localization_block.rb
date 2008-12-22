class LocalizationBlock < Block

  def self.description
    _('Localization map block')
  end

  def help
    _('Shows where the profile is on the material world.')
  end

  def content
    profile = self.owner
    title = self.title
    lambda do
      profile.lat ?
      block_title(title) +
      content_tag('div',
      '<img src="http://maps.google.com/staticmap?center='+profile.lat.to_s()+','+profile.lng.to_s()+'&zoom=8&size=205x250&maptype=roadmap&markers='+profile.lat.to_s()+','+profile.lng.to_s()+',green&key='+GoogleMaps::key+'&sensor=false"/>',
      :class => 'the-localization-map' ) :
      content_tag('i', _('This profile has no geographical position registered.'))
    end
  end

end
