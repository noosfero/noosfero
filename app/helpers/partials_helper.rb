module PartialsHelper

  def partial_for_class_in_view_path(klass, view_path, prefix = nil, suffix = nil)
    return nil if klass.nil?
    name = [prefix, klass.name.underscore, suffix].compact.map(&:to_s).join('_')

    search_name = String.new(name)
    if search_name.include?("/")
      search_name.gsub!(/(\/)([^\/]*)$/,'\1_\2')
      name = File.join(params[:controller], name) if defined?(params) && params[:controller]
    else
      search_name = "_" + search_name
    end

    path = defined?(params) && params[:controller] ? File.join(view_path, params[:controller], search_name + '.html.erb') : File.join(view_path, search_name + '.html.erb')
    return name if File.exists?(File.join(path))

    partial_for_class_in_view_path(klass.superclass, view_path, prefix, suffix)
  end

  def partial_for_class(klass, prefix=nil, suffix=nil)
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' if klass.nil?
    name = klass.name.underscore
    controller.view_paths.each do |view_path|
      partial = partial_for_class_in_view_path(klass, view_path, prefix, suffix)
      return partial if partial
    end

    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?'
  end

  def render_partial_for_class klass, *args
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' if klass.nil?
    begin
      partial = klass.name.underscore
      partial = "#{params[:controller]}/#{partial}" if params[:controller] and partial.index '/'
      return render partial, *args
    rescue ActionView::MissingTemplate
      return render_partial_for_class klass.superclass, *args
    end
  end

end
