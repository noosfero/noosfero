module SearchTermHelper
  def register_search_term(term, total, indexed, context, asset='all')
    normalized_term = normalize_term(term)
    if normalized_term.present?
      search_term = SearchTerm.find_or_create(normalized_term, context, asset)
      SearchTermOccurrence.create!(:search_term => search_term, :total => total, :indexed => indexed)
    end
  end

  #FIXME For some reason the job is created but nothing is ran.
  #handle_asynchronously :register_search_term

  #TODO Think better on how to normalize them properly
  def normalize_term(search_term)
    search_term
  end
end
