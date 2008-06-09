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
    content_tag('table',
      content_tag('tr',
        content_tag('td', content_tag('div', profile_image(profile, :thumb), :class => 'profile-info-picture')) +
        content_tag('td', content_tag('strong', profile.name) + '<br/>' + link_to(url_for(profile.url), profile.url) + '<br/>')
      ),
      :class => 'profile-info'
    )
  end

end
