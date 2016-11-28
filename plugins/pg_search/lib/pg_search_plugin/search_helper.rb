module PgSearchPlugin::SearchHelper

  def facet(f)
    html_id = "#{f[:name].to_slug}-facet"

    result = content_tag('h2', _(f[:name]))
    result += link_to(_('Clear'), '', :class => 'clear-facet icon-clear', 'data-facet' => html_id)
    result += text_field_tag(nil, nil, :placeholder => _('Refine options'), :class => 'facet-refine')
    result += facets_block(f[:options], f[:type])

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

  def date_filter(attribute, period)
    if period.present?
      start_date = period['start_date'].present? ? DateTime.parse(period['start_date']) : nil
      end_date = period['end_date'].present? ? DateTime.parse(period['end_date']) : nil
    else
      start_date = nil
      end_date = nil
    end
    result = content_tag('h2', _(attribute.to_s.humanize))
    result += content_tag('div', date_range_field("periods[#{attribute}][start_date]", "periods[#{attribute}][end_date]", start_date, end_date, {}, {:from_id => "datepicker-from-#{attribute}", :to_id =>  "datepicker-to-#{attribute}"}))
    content_tag('div', result, :class => 'period', :id => "#{attribute.to_s.to_slug}-period")
  end
end
