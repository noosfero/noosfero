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
      :onclick => "window.open('http://wikimapia.org/#lat=#{profile.lat.to_s()}&lon=#{profile.lng.to_s()}&z=12&l=0&m=m&v=2','_blank','width=750,height=500')",
      :class => 'the-localization-map' ) :
      content_tag('i', _('This profile has no geographical position registered.'))
    end
  end

end
