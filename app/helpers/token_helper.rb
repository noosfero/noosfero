module TokenHelper

  def jquery_token_input_messages_json(hintText = _('Type in an keyword'), noResultsText = _('No results'), searchingText = _('Searching...'))
    "hintText: '#{hintText}', noResultsText: '#{noResultsText}', searchingText: '#{searchingText}'"
  end

  def token_input_field_tag(name, element_id, search_action, options = {}, text_field_options = {}, html_options = {})
    options[:min_chars] ||= 3
    options[:hint_text] ||= _("Type in a search term")
    options[:no_results_text] ||= _("No results")
    options[:searching_text] ||= _("Searching...")
    options[:search_delay] ||= 1000
    options[:prevent_duplicates] ||=  true
    options[:backspace_delete_item] ||= false
    options[:zindex] ||= 999
    options[:focus] ||= false
    options[:avoid_enter] ||= true
    options[:on_result] ||= 'null'
    options[:on_add] ||= 'null'
    options[:on_delete] ||= 'null'
    options[:on_ready] ||= 'null'
    options[:query_param] ||= 'q'

    result = text_field_tag(name, nil, text_field_options.merge(html_options.merge({:id => element_id})))
    result += javascript_tag("jQuery('##{element_id}')
      .tokenInput('#{url_for(search_action)}', {
        minChars: #{options[:min_chars].to_json},
        prePopulate: #{options[:pre_populate].to_json},
        hintText: #{options[:hint_text].to_json},
        noResultsText: #{options[:no_results_text].to_json},
        searchingText: #{options[:searching_text].to_json},
        searchDelay: #{options[:search_delay].to_json},
        preventDuplicates: #{options[:prevent_duplicates].to_json},
        backspaceDeleteItem: #{options[:backspace_delete_item].to_json},
        zindex: #{options[:zindex].to_json},
        queryParam: #{options[:query_param].to_json},
        tokenLimit: #{options[:token_limit].to_json},
        onResult: #{options[:on_result]},
        onAdd: #{options[:on_add]},
        onDelete: #{options[:on_delete]},
        onReady: #{options[:on_ready]},
      });
    ")
    result += javascript_tag("jQuery('##{element_id}').focus();") if options[:focus]
    if options[:avoid_enter]
      result += javascript_tag("jQuery('#token-input-#{element_id}')
                    .live('keydown', function(event){
                    if(event.keyCode == '13') return false;
                    });")
    end
    result
  end

end
