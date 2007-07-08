# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def show_block(owner,box_number)
    blocks = owner.boxes.find(:first, :conditions => ['number = ?', box_number]).blocks
    @out = content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, eval(b.to_html), :class =>"block_item_box_#{b.box_id}" , :id => "block_#{b.id}" ) + draggable('block_'+b.id.to_s)
      }, :id => "leo_#{box_number}"
    ) + drag_drop_item(box_number)
    
#TODO when we put this parameter the elements stay blocked into the div element indicated.
#THe consequence is we can't move the element between boxes. Comment it the element can be sorted
#only when we move a element
# sortable_block(box_number)
  end

  def sortable_block(box_number)
    sortable_element "leo_#{box_number}",
    :complete => visual_effect(:highlight, "leo_#{box_number}"),
    :url => {:action => 'sort_box', :box_number => box_number }
  end

  def draggable item
    draggable_element(item, :ghosting=>true, :revert=>true)
  end

  def drag_drop_item box_id
    boxes =  Box.find_not_box(box_id)
    return boxes.map{ |b|
    drop_receiving_element("box_#{box_id}",
      :accept     => "block_item_box_#{b.id}",
      :complete   => "$('spinner').hide();",
      :before     => "$('spinner').show();",
      :hoverclass => 'hover',
      :with       => "'block=' + encodeURIComponent(element.id.split('_').last())",
      :url        => {:action=>:change_box, :box_id=> box_id})
    }.to_s
  end

end
