module SearchHelper

  STOP_WORDS = {
    'pt_BR' => Ferret::Analysis::FULL_PORTUGUESE_STOP_WORDS,
    'en'    => Ferret::Analysis::FULL_ENGLISH_STOP_WORDS,
  }
  
  def relevance_for(hit)
    n = (hit.ferret_score if hit.respond_to?(:ferret_score))
    n ||= 1.0
    (n * 100.0).round
  end

  def remove_stop_words(query)
    (query.downcase.scan(/"[^"]*"?|'[^']*'?|[^'"\s]+/) - (STOP_WORDS[locale] || [])).join(' ')
  end

  def display_results

    unless GoogleMaps.enabled?
      return render(:partial => 'display_results')
    end

    data =
      if params[:display] == 'map'
        {
          :partial => 'google_maps',
          :toggle => button(:search, _('Display in list'), params.merge(:display => 'list'), :class => "map-toggle-button" ),
          :class => 'map' ,
        }
      else
        {
          :partial => 'display_results',
          :toggle => button(:search, _('Display in map'), params.merge(:display => 'map'), :class => "map-toggle-button" ),
          :class => 'list' ,
        }
      end

    content_tag('div', data[:toggle] + (render :partial => data[:partial]), :class => "map-or-list-search-results #{data[:class]}")
  end

  def display_profile_info(profile)
    # FIXME add distance
    data = ''
    unless profile.contact_email.nil?
      data << content_tag('strong', _('E-Mail: ')) + profile.contact_email + '<br/>'
    end
    unless profile.contact_phone.nil?
      data << content_tag('strong', _('Phone(s): ')) + profile.contact_phone + '<br/>'
    end
    unless profile.address.nil?
      data << content_tag('strong', _('Address: ')) + profile.address + '<br/>'
    end
    unless profile.products.empty?
      data << content_tag('strong', _('Products/Services: ')) + profile.products.map{|i| link_to(i.name, :controller => 'catalog', :profile => profile.identifier, :action => 'show', :id => i)}.join(', ') + '<br/>'
    end
    content_tag('table',
      content_tag('tr',
        content_tag('td', content_tag('div', profile_image(profile, :thumb), :class => 'profile-info-picture')) +
        content_tag('td', content_tag('strong', link_to(profile.name, url_for(profile.url))) + '<br/>' + data
        )
      ),
      :class => 'profile-info'
    )
  end

end
