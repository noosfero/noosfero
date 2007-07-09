# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def display_boxes(boxes, main_content)
    boxes.map do |box| 
      content_tag(:div, show_blocks(box, main_content) ,:id=>"box_#{box.number}")
    end
  end

  def show_blocks(box, main_content)
    blocks = box.blocks
    content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, b.main? ? main_content : b.to_html, :class =>"block_item_box_#{b.box_id}" , :id => "block_#{b.id}" ) + draggable('block_'+b.id.to_s)
      }, :id => "sort_#{box.number}"
    ) + drag_drop_item(box.number) + sortable_block(box.number)
  end

  def sortable_block(box_number)
    sortable_element "sort_#{box_number}",
    :complete => visual_effect(:highlight, "sort_#{box_number}"),
    :url => {:action => 'sort_box', :box_number => box_number }
  end

  def draggable(item)
    draggable_element(item, :ghosting=>true, :revert=>true)
  end

  def drag_drop_item box_number
    boxes =  Box.find_not_box(box_number)

    boxes.map{ |b|
      drop_receiving_element("box_#{box_number}",
        :accept     => "block_item_box_#{b.number}",
        :complete   => "$('spinner').hide();",
        :before     => "$('spinner').show();",
        :hoverclass => 'hover',
        :with       => "'block=' + encodeURIComponent(element.id.split('_').last())",
        :url        => {:action=>:change_box, :box_id => box_number})
      }.to_s
  end


end
