module SearchHelper
  def partial_for_hit(klass)
    name = klass.name.underscore
    if File.exists?(File.join(RAILS_ROOT, 'app', 'views', 'search', "_#{name}.rhtml"))
      name
    else
      partial_for_hit(klass.superclass)
    end
  end
end
