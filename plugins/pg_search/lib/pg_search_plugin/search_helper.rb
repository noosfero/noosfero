module PgSearchPlugin::SearchHelper

  def facet(f)
    html_id = "#{f[:name].to_slug}-facet"

    result = content_tag('h2', _(f[:name]))
    result += text_field_tag(nil, nil, :placeholder => _('Refine options'), :class => 'facet-refine')
    result += facets_block(f[:options], f[:type])
    result += button(:clear, _('Clear filters'), nil, class: 'clear-facet', 'data-facet' => html_id )

    content_tag('div', result, :id => html_id, :class => 'facet')
  end

  def facets_block(facets, type)
    html_options = {:class => 'facets-block'}

    content_tag('div',
      facets.map do |option|
        if option[:value].blank?
          value = ' '
          input_label = _('Undefined')
        else
          value = option[:value]
          input_label = option[:label]
        end
        content_tag('div',
          labelled_check_box(input_label, "facets[#{option[:identifier]}][#{value}]", '1', option[:enabled], :disabled => option[:count] == 0) +
          content_tag('span', "(#{option[:count]})", :class => 'facet-count'),
          :class => "facet-option #{'undefined-value' if value == ' '}"
        )
      end.join("\n").html_safe, html_options)
  end

  def date_filter(attribute, period, is_metadata)
    if period.present?
      start_date = period['start_date'].present? ? DateTime.parse(period['start_date']) : nil
      end_date = period['end_date'].present? ? DateTime.parse(period['end_date']) : nil
    else
      start_date = nil
      end_date = nil
    end
    result = content_tag('h2', _(attribute.to_s.humanize))
    result += content_tag('div', date_range_field("periods[#{attribute}][start_date]", "periods[#{attribute}][end_date]", start_date, end_date, {}, {:from_id => "datepicker-from-#{attribute.to_s.to_slug}", :to_id =>  "datepicker-to-#{attribute.to_s.to_slug}"}))
    result += hidden_field_tag("periods[#{attribute}][is_metadata]", is_metadata)
    content_tag('div', result, :class => 'period', :id => "#{attribute.to_s.to_slug}-period")
  end

  def custom_field_names klass, scope
    class_name = klass.name.pluralize.downcase
    scope_ids = scope.map(&:id)
    scope_filter = scope_ids.blank? ? "" : "t.id IN (#{scope_ids.join(',')}) AND"
    ActiveRecord::Base.connection.execute("SELECT DISTINCT b.value->>'name', b.value->>'type' " \
                                          "FROM #{class_name} t, jsonb_each(t.metadata->'custom_fields') b " \
                                          "WHERE #{scope_filter} (b.value->>'name') IS NOT NULL AND (b.value->>'public' = '1')").values
  end

  def custom_field_values klass, scope, field
    class_name = klass.name.pluralize.downcase
    scope_ids = scope.map(&:id)
    scope_filter = scope_ids.blank? ? "" : "t.id IN (#{scope_ids.join(',')}) AND"
    ActiveRecord::Base.connection.execute("SELECT b.value->>'value', count(b.value->>'value') FROM #{class_name} t, " \
                                          "jsonb_each(t.metadata->'custom_fields') b WHERE #{scope_filter} " \
                                          "b.value->>'name' = '#{field[:attribute]}' AND b.value->>'type' = '#{field[:type]}' AND (b.value->>'public' = '1')" \
                                          "GROUP BY b.value").values
  end

  def search_field_identifier field_name, field_type = nil
    "#{field_name.to_s.to_slug}" + (field_type ? "-#{field_type}": "")
  end

  def default_search_fields
    [['Types', nil], ['Content types', nil], ['Tags', nil], ['Categories', nil],
     ['Created at', :date], ['Updated at', :date], ['Published at', :date]]
  end
end
