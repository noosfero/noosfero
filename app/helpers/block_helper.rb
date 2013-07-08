module BlockHelper

  def block_title(title)
    tag_class = 'block-title'
    tag_class += ' empty' if title.empty?
    content_tag 'h3', content_tag('span', h(title)), :class => tag_class
  end

  def highlights_block_config_image_fields(block, image={})
    "
    <tr class=\"image-data-line\">
      <td>
        #{select_tag 'block[images][][image_id]', content_tag(:option) + option_groups_from_collection_for_select(block.folder_choices, :images, :name, :id, :name, image[:image_id].to_i).html_safe}
      </td>
      <td>#{text_field_tag 'block[images][][address]', image[:address], :class => 'highlight-address', :size => 20}</td>
      <td>#{text_field_tag 'block[images][][position]', image[:position], :class => 'highlight-position', :size => 1}</td>
    </tr><tr class=\"image-title\">
      <td colspan=\"3\"><label>#{
        content_tag('span', _('Title')) +
        text_field_tag('block[images][][title]', image[:title], :class => 'highlight-title', :size => 45)
      }</label></td>
    </tr>
    "
  end

end
