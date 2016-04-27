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


  def partial_for_class(klass, prefix=nil, suffix=nil)
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' if klass.nil?
    name = klass.name.underscore
    controller.view_paths.each do |view_path|
      partial = partial_for_class_in_view_path(klass, view_path, prefix, suffix)
      return partial if partial
    end

    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?'
  end

  ##
  # Calculate partial name with prefix and suffix
  # Togheter with render_partial_for_class,
  # it should replace #partial_for_class_in_view_path in the future
  #
  def partial_name_for underscore, prefix = nil, suffix = nil
    parts = underscore.split '/'
    if prefix or suffix
      partial = [prefix, parts.last, suffix].compact.map(&:to_s).join '_'
    else
      partial = parts.last
    end
    if parts.size > 1
      "#{params[:controller]}/#{parts.first}/#{partial}"
    else
      partial
    end
  end

  def render_for_class klass, *args, &block
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' unless klass
    begin
      capture klass, &block
    rescue ActionView::MissingTemplate
      render_for_class klass.superclass, *args, &block
    end
  end

  def render_partial_for_class klass, *args
    render_for_class klass do |klass|
      render partial_name_for(klass.name.underscore), *args
    end
  end

end
