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
    data =
      if params[:display] == 'map'
        {
          :partial => 'google_maps',
          :toggle => link_to(_('Display in list'), params.merge(:display => 'list'))
        }
      else
        {
          :partial => 'display_results',
          :toggle => link_to(_('Display in map'), params.merge(:display => 'map'))
        }
      end

    data[:toggle] + (render :partial => data[:partial])
  end

end
