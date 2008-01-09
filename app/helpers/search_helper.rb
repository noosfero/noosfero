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
    (query.downcase.split(' ') - STOP_WORDS[Locale.current.to_s]).join(' ')
  end
end
