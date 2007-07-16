# Methods added to this helper will be available to all templates in the application.
module EditTemplateHelper

  private

  # Shows the blocks as defined in <tt>show_blocks</tt> adding the sortable and draggable elements.
  # In this case the layout can be manipulated
  def edit_blocks(box, main_content = "")
    blocks = box.blocks_sort_by_position
    content_tag(:ul, box.name + 
      link_to_remote(_('sort'), {:update => "sort_#{box.number}", :url => {:action => 'set_sort_mode', :box_id => box.id }}, :class => 'sort_button')  +
      blocks.map {|b| 
       content_tag(:li, b.name, :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}" ) + draggable("block_#{b.id}")
      }.to_s, :id => "sort_#{box.number}"
    ) + drag_drop_items(box)
  end

  # Allows the biven box to have sortable elements
  def sortable_block(box_number)
    sortable_element "sort_#{box_number}",
    :url => {:action => 'sort_box', :box_number => box_number },
    :complete => visual_effect(:highlight, "sort_#{box_number}")
  end

  # Allows an element item to be draggable
  def draggable(item)
    draggable_element(item, :ghosting => true, :revert => true)
  end

  # Allows an draggable element change between diferrents boxes
  def drag_drop_items(box)
    boxes =  Box.find_not_box(box.id)

    boxes.map{ |b|
      drop_receiving_element("box_#{box.number}",
        :accept     => "block_item_box_#{b.number}",
        :complete   => "$('spinner').hide();",
        :before     => "$('spinner').show();",
        :hoverclass => 'hover',
        :with       => "'block=' + encodeURIComponent(element.id.split('_').last())",
        :url        => {:action=>:change_box, :box_id => box.id})
      }.to_s
  end


end
