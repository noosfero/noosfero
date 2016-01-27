module BlockHelper

  def block_title(title, subtitle=nil)
    block_header = block_heading title
    block_header += block_heading(subtitle, 'h4') if subtitle
    content_tag 'div', block_header, :class => 'block-header'
  end

  def block_heading(title, heading='h3')
    tag_class = 'block-' + (heading == 'h3' ? 'title' : 'subtitle')
    tag_class += ' empty' if title.empty?
    content_tag heading, content_tag('span', h(title)), :class => tag_class
  end

  def highlights_block_config_image_fields(block, image={}, row_number=nil)
    "
    <tr class=\"image-data-line\" data-row-number='#{row_number}'>
      <td>
        #{select_tag 'block[images][][image_id]', content_tag(:option) + option_groups_from_collection_for_select(block.folder_choices, :images, :name, :id, :name, image[:image_id].to_i).html_safe}
      </td>
      <td>#{text_field_tag 'block[images][][address]', image[:address], :class => 'highlight-address', :size => 20}</td>
      <td>#{text_field_tag 'block[images][][position]', image[:position], :class => 'highlight-position', :size => 1}</td>
      <td>#{check_box_tag 'block[images][][new_window]', '1', image[:new_window], :class => 'highlight-new_window', :size => 1}</td>
    </tr><tr class=\"image-title\" data-row-number='#{row_number}'>
      <td colspan=\"3\"><label>#{
        content_tag('span', _('Title')) +
        text_field_tag('block[images][][title]', image[:title], :class => 'highlight-title', :size => 45)
      }</label></td>
      <td>#{button_without_text(:delete, _('Remove'), '#', class: 'delete-highlight', data: {confirm: _('Are you sure you want to remove this highlight')})}</td>
    </tr>
    "
  end

end
