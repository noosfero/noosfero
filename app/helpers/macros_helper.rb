module MacrosHelper

  def macros_in_menu
    Environment.macros[@environment.id].reject{ |macro_name, plugin_instance| macro_configuration(macro_name)[:icon_path] }
  end

  def macros_with_buttons
    Environment.macros[@environment.id].reject{ |macro_name, plugin_instance| !macro_configuration(macro_name)[:icon_path] }
  end

  def macro_configuration(macro_name)
    plugin_instance = Environment.macros[@environment.id][macro_name]
    plugin_instance.send("config_#{macro_name}")
  end

  def macro_title(macro_name)
    macro_configuration(macro_name)[:title] || macro_name.to_s.humanize
  end
  
  def generate_macro_config_dialog(macro_name)
    if macro_configuration(macro_name)[:skip_dialog]
      "function(){#{macro_generator(macro_name)}}"
    else
      "function(){
        jQuery('<div>'+#{macro_configuration_dialog(macro_name).to_json}+'</div>').dialog({
          title: #{macro_title(macro_name).to_json},
          modal: true,
          buttons: [
            {text: #{_('Ok').to_json}, click: function(){
              tinyMCE.activeEditor.execCommand('mceInsertContent', false,
              (function(dialog){ #{macro_generator(macro_name)} })(this));
              jQuery(this).dialog('close');
            }},
            {text: #{_('Cancel').to_json}, click: function(){jQuery(this).dialog('close');}}
          ]
        });
      }"
    end
  end

  def include_macro_js_files
    plugins_javascripts = []
    Environment.macros[environment.id].map do |macro_name, plugin_instance|
      if macro_configuration(macro_name)[:js_files]
        macro_configuration(macro_name)[:js_files].map { |js| plugins_javascripts << plugin_instance.class.public_path(js) } 
      end
    end
    javascript_include_tag(plugins_javascripts, :cache => 'cache/plugins-' + Digest::MD5.hexdigest(plugins_javascripts.to_s)) unless plugins_javascripts.empty?
  end

  def macro_css_files
    plugins_css = []
    Environment.macros[environment.id].map do |macro_name, plugin_instance|
      if macro_configuration(macro_name)[:css_files]
        macro_configuration(macro_name)[:css_files].map { |css| plugins_css << plugin_instance.class.public_path(css) } 
      end
    end
    plugins_css.join(',')
  end

  protected
  
  def macro_generator(macro_name)
    if macro_configuration(macro_name)[:generator]
      macro_configuration(macro_name)[:generator]
    else
      macro_default_generator(macro_name)
    end
  end
  
  def macro_default_generator(macro_name)
    code = "var params = {};"
    configuration = macro_configuration(macro_name)
    configuration[:params].map do |field|
      code += "params.#{field[:name]} = jQuery('*[name=#{field[:name]}]', dialog).val();"
    end
    code + "
      var html = jQuery('<div class=\"macro mceNonEditable\" data-macro=\"#{macro_name[6..-1]}\">'+#{macro_title(macro_name).to_json}+'</div>')[0];
      for(key in params) html.setAttribute('data-macro-'+key,params[key]);
      return html.outerHTML;
    "
  end

  def macro_configuration_dialog(macro_name)
    macro_configuration(macro_name)[:params].map do |field|
      label_name = field[:label] || field[:name].to_s.humanize
      case field[:type]
      when 'text'
        labelled_form_field(label_name, text_field_tag(field[:name], field[:default]))
      when 'select'
        labelled_form_field(label_name, select_tag(field[:name], options_for_select(field[:values], field[:default])))
      end
    end.join("\n")
  end

end
