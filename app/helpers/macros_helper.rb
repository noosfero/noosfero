module MacrosHelper

  def macros_in_menu
    @plugins.dispatch(:macros).reject{ |macro| macro.configuration[:icon_path] }
  end

  def macros_with_buttons
    @plugins.dispatch(:macros).reject{ |macro| !macro.configuration[:icon_path] }
  end

  def macro_title(macro)
    macro.configuration[:title] || macro.name.humanize
  end

  def generate_macro_config_dialog(macro)
    if macro.configuration[:skip_dialog]
      "function(){#{macro_generator(macro)}}"
    else
      "function(){
        jQuery('<div>'+#{macro_configuration_dialog(macro).to_json}+'</div>').dialog({
          title: #{macro_title(macro).to_json},
          modal: true,
          buttons: {
            #{_('Ok').to_json}: function(){
              tinyMCE.activeEditor.execCommand('mceInsertContent', false,
              (function(dialog){ #{macro_generator(macro)} })(this));
              jQuery(this).dialog('close');
            },
            #{_('Cancel').to_json}: function(){
              jQuery(this).dialog('close');
            }
          }
        });
      }"
    end
  end

  def include_macro_js_files
    plugins_javascripts = []
    @plugins.dispatch(:macros).map do |macro|
      if macro.configuration[:js_files]
        [macro.configuration[:js_files]].flatten.map { |js| plugins_javascripts << macro.plugin.public_path(js) }
      end
    end
    unless plugins_javascripts.empty?
      javascript_include_tag *plugins_javascripts
    end
  end

  def macro_css_files
    plugins_css = []
    @plugins.dispatch(:macros).map do |macro|
      if macro.configuration[:css_files]
        [macro.configuration[:css_files]].flatten.map { |css| plugins_css << macro.plugin.public_path(css) }
      end
    end
    plugins_css.join(',')
  end

  protected

  def macro_generator(macro)
    if macro.configuration[:generator]
      if macro.configuration[:generator].respond_to?(:call)
        macro.configuration[:generator].call(macro)
      else
        macro.configuration[:generator]
      end
    else
      macro_default_generator(macro)
    end

  end

  def macro_default_generator(macro)
    code = "var params = {};"
    macro.configuration[:params].map do |field|
      code += "params.#{field[:name]} = jQuery('*[name=#{field[:name]}]', dialog).val();"
    end
    code + "
      var html = jQuery('<div class=\"macro mceNonEditable\" data-macro=\"#{macro.identifier}\">'+#{macro_title(macro).to_json}+'</div>')[0];
      for(key in params) html.setAttribute('data-macro-'+key,params[key]);
      return html.outerHTML;
    "
  end

  def macro_configuration_dialog(macro)
    macro.configuration[:params].map do |field|
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
