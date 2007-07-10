# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # This method expect an array of boxes and the content retuned of a controller action
  def display_boxes(boxes, main_content = "")
    # If no boxes is passed return the main content 
    return main_content if boxes.nil?

    #Generate all boxes of the current profile and considering the defined on template.
    content = boxes.map do |box| 
      content_tag(:div, edit_mode? ? edit_blocks(box, main_content) : show_blocks(box, main_content) , :id=>"box_#{box.number}")
    end

    #In case of edit mode add a new div with a class named 'edit_mode' covering all div boxes.
    content = content_tag(:div, content, :class => 'edit_mode') if edit_mode?

    content
  end

  private

  def edit_mode?
    true if controller.controller_name == 'edit_template'
  end

  def show_blocks(box, main_content = "")
    blocks = box.blocks_sort_by_position
    content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, b.main? ? main_content : b.to_html, :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}" )
      }, :id => "sort_#{box.number}"
    ) 
  end

  def edit_blocks(box, main_content = "")
    blocks = box.blocks_sort_by_position
    content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, b.main? ? main_content : b.to_html , :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}" ) + draggable("block_#{b.id}")
      }, :id => "sort_#{box.number}"
    ) + drag_drop_items(box) + sortable_block(box.number)
  end

  def sortable_block(box_number)
    sortable_element "sort_#{box_number}",
    :url => {:action => 'sort_box', :box_number => box_number },
    :complete => visual_effect(:highlight, "sort_#{box_number}")
  end

  def draggable(item)
    draggable_element(item, :ghosting=>true, :revert=>true)
  end

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
