module SearchHelper

  def partial_for_hit(klass)
    name = klass.name.underscore
    if File.exists?(File.join(RAILS_ROOT, 'app', 'views', 'search', "_#{name}.rhtml"))
      name
    else
      partial_for_hit(klass.superclass)
    end
  end

  def relevance_for(hit)
    n = (hit.ferret_score if hit.respond_to?(:ferret_score))
    n ||= 1.0
    (n * 100.0).round
  end
end
