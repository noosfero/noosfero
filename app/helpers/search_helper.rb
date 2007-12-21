module SearchHelper

  def relevance_for(hit)
    n = (hit.ferret_score if hit.respond_to?(:ferret_score))
    n ||= 1.0
    (n * 100.0).round
  end
end
