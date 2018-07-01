module PrototypeHelper
    
  CALLBACKS = Set.new([ :create, :uninitialized, :loading, :loaded, :interactive, :complete, :failure, :success ] + (100..599).to_a)
  AJAX_OPTIONS = Set.new([ :before, :after, :condition, :url, :asynchronous, :method, :insertion, :position, :form, :with, :update, :script, :type ]).merge(CALLBACKS)
    
  def drop_receiving_element_js(element_id, options = {})
    options[:with]     ||= "'id=' + encodeURIComponent(element.id)"
    options[:onDrop]   ||= "function(element){" + remote_function(options) + "}"
    options.delete_if { |key, value| AJAX_OPTIONS.include?(key) }

    options[:accept] = array_or_string_for_javascript(options[:accept]) if options[:accept]
    options[:hoverclass] = "'#{options[:hoverclass]}'" if options[:hoverclass]

    options.delete(:confirm) if options[:confirm]

    %(Droppables.add(#{ActiveSupport::JSON.encode(element_id)}, #{options_for_javascript(options)});)
  end

  def link_to_function(name, function, html_options = {})
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end

  def link_to_remote(name, options = {}, html_options = nil)
    link_to_function(name, remote_function(options), html_options || options.delete(:html))
  end

  def remote_function(options)
    javascript_options = options_for_ajax(options)

    update = ''
    if options[:update] && options[:update].is_a?(Hash)
      update  = []
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ?
      "new Ajax.Request(" :
      "new Ajax.Updater(#{update}, "

    url_options = options[:url]
    function << "'#{html_escape(escape_javascript(url_for(url_options)))}'"
    function << ", #{javascript_options})"

    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
    function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

    return function.html_safe
  end

  def options_for_ajax(options)
    js_options = build_callbacks(options)

    js_options['asynchronous'] = options[:type] != :synchronous
    js_options['method']       = method_option_to_s(options[:method]) if options[:method]
    js_options['insertion']    = "'#{options[:position].to_s.downcase}'" if options[:position]
    js_options['evalScripts']  = options[:script].nil? || options[:script]

    if options[:form]
      js_options['parameters'] = 'Form.serialize(this)'
    elsif options[:submit]
      js_options['parameters'] = "Form.serialize('#{options[:submit]}')"
    elsif options[:with]
      js_options['parameters'] = options[:with]
    end

    if protect_against_forgery? && !options[:form]
      if js_options['parameters']
        js_options['parameters'] << " + '&"
      else
        js_options['parameters'] = "'"
      end
      js_options['parameters'] << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
    end

    options_for_javascript(js_options)
  end

  def options_for_javascript(options)
    if options.empty?
      '{}'
    else
      "{#{options.keys.map { |k| "#{k}:#{options[k]}" }.sort.join(', ')}}"
    end
  end

  def build_callbacks(options)
    callbacks = {}
    options.each do |callback, code|
      if CALLBACKS.include?(callback)
        name = 'on' + callback.to_s.capitalize
        callbacks[name] = "function(request){#{code}}"
      end
    end
    callbacks
  end

  def singular_class_name(record_or_class)
    model_name_from_record_or_class(record_or_class).singular
  end

  def remote_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    when Array
      object = record_or_name_or_array.last
      object_name = singular_class_name(object)
      apply_form_for_options!(record_or_name_or_array, options)
      args.unshift object
    else
      object = record_or_name_or_array
      object_name = singular_class_name(record_or_name_or_array)
      apply_form_for_options!(nil, object, options)
      args.unshift object
    end

    concat(form_remote_tag(options))
    fields_for(object_name, *(args << options), &proc)
    concat('</form>'.html_safe)
  end

  def form_remote_tag(options = {}, &block)
    options[:form] = true

    options[:html] ||= {}
    options[:html][:onsubmit] =
      (options[:html][:onsubmit] ? options[:html][:onsubmit] + "; " : "") +
      "#{remote_function(options)}; return false;"

    form_tag(options[:html].delete(:action) || url_for(options[:url]), options[:html], &block)
  end

  def draggable_element_js(element_id, options = {})
    %(new Draggable(#{ActiveSupport::JSON.encode(element_id)}, #{options_for_javascript(options)});)
  end

  def draggable_element(element_id, options = {})
    javascript_tag(draggable_element_js(element_id, options).chop!)
  end

  def array_or_string_for_javascript(option)
    if option.kind_of?(Array)
      "['#{option.join('\',\'')}']"
    elsif !option.nil?
      "'#{option}'"
    end
  end

  def drop_receiving_element(element_id, options = {})
    javascript_tag(drop_receiving_element_js(element_id, options).chop!)
  end

  def build_observer(klass, name, options = {})
    if options[:with] && (options[:with] !~ /[\{=(.]/)
      options[:with] = "'#{options[:with]}=' + encodeURIComponent(value)"
    else
      options[:with] ||= 'value' unless options[:function]
    end

    callback = options[:function] || remote_function(options)
    javascript  = "new #{klass}('#{name}', "
    javascript << "#{options[:frequency]}, " if options[:frequency]
    javascript << "function(element, value) {"
    javascript << "#{callback}}"
    javascript << ")"
    javascript_tag(javascript)
  end

  def observe_field(field_id, options = {})
    if options[:frequency] && options[:frequency] > 0
      build_observer('Form.Element.Observer', field_id, options)
    else
      build_observer('Form.Element.EventObserver', field_id, options)
    end
  end
end
