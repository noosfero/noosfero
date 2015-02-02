module BscPlugin::BscHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TextHelper

  def token_input_field_tag(name, element_id, search_action, options = {}, text_field_options = {}, html_options = {})
    options[:min_chars] ||= 3
    options[:hint_text] ||= c_("Type in a search term")
    options[:no_results_text] ||= c_("No results")
    options[:searching_text] ||= c_("Searching...")
    options[:search_delay] ||= 1000
    options[:prevent_duplicates] ||=  true
    options[:backspace_delete_item] ||= false
    options[:focus] ||= false
    options[:avoid_enter] ||= true
    options[:on_result] ||= 'null'
    options[:on_add] ||= 'null'
    options[:on_delete] ||= 'null'
    options[:on_ready] ||= 'null'

    result = text_field_tag(name, nil, text_field_options.merge(html_options.merge({:id => element_id})))
    result +=
    "
    <script type='text/javascript'>
      jQuery('##{element_id}')
      .tokenInput('#{url_for(search_action)}', {
        minChars: #{options[:min_chars].to_json},
        prePopulate: #{options[:pre_populate].to_json},
        hintText: #{options[:hint_text].to_json},
        noResultsText: #{options[:no_results_text].to_json},
        searchingText: #{options[:searching_text].to_json},
        searchDelay: #{options[:serach_delay].to_json},
        preventDuplicates: #{options[:prevent_duplicates].to_json},
        backspaceDeleteItem: #{options[:backspace_delete_item].to_json},
        queryParam: #{name.to_json},
        tokenLimit: #{options[:token_limit].to_json},
        onResult: #{options[:on_result]},
        onAdd: #{options[:on_add]},
        onDelete: #{options[:on_delete]},
        onReady: #{options[:on_ready]},
      })
      "
      result += options[:focus] ? ".focus();" : ";"
      if options[:avoid_enter]
        result += "jQuery('#token-input-#{element_id}')
                    .live('keydown', function(event){
                    if(event.keyCode == '13') return false;
                  });"
      end
      result += "</script>"
      result
  end

  def product_display_name(product)
    "#{product.name} (#{product.enterprise.name})"
  end

  def display_text_field(name, value, options={:display_nil => false, :nil_symbol => '---'})
    value = value.to_s
    if !value.blank? || options[:display_nil]
      value = value.blank? ? options[:nil_symbol] : value
      content_tag('tr', content_tag('td', name+': ', :class => 'bsc-field-label') + content_tag('td', value, :class => 'bsc-field-value'))
    end
  end

  def display_list_field(list, options={:nil_symbol => '---'})
    list.map do |item|
      item = item.blank? ? options[:nil_symbol] : item
      content_tag('tr', content_tag('td', item, :class => 'bsc-field-value'))
    end.join
  end

  def short_text(name, chars = 40)
    truncate name, :length => chars, :omission => '...'
  end

end
