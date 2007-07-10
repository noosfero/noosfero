# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  REJECTED_DIRS = %w[
    .
    ..
    .svn
  ]

  # This method expect an array of boxes and the content retuned of a controller action
  # It will generate the boxes div according the yaml definition
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

  # Load all the css files of a existing template with the template_name passed as argument.
  #
  # The files loaded are in the path:
  #
  # 'public/templates/#{template_name}/stylesheets/*'
  #TODO I think that implements this idea describe above it's good. Let's discuss about it.
  # OBS: If no files are found in path the default template is used
  def stylesheet_link_tag_template(template_name)
    d = Dir.new("public/templates/#{template_name}/stylesheets/") 
    d.map do |filename| 
      stylesheet_link_tag("/templates/#{template_name}/stylesheets/#{filename}") unless REJECTED_DIRS.include?(filename.gsub(/.css/,""))
    end
  end

  # Load all the javascript files of a existing template with the template_name passed as argument.
  #
  # The files loaded are in the path:
  #
  # 'public/templates/#{template_name}/javascripts/*'
  #
  #TODO I think that implements this idea describe above it's good. Let's discuss about it.
  # OBS: If no files are found in path the default template is used
  def javascript_include_tag_template(template_name)
    d = Dir.new("public/templates/#{template_name}/javascripts/") 
    d.map do |filename| 
      javascript_include_tag("/templates/#{template_name}/javascripts/#{filename}") unless REJECTED_DIRS.include?(filename.gsub(/.js/,""))
    end
  end

  private

  # Check if the current controller is the controller that allows layout editing
  def edit_mode?
    controller.controller_name == 'edit_template' ? true : false
  end

  # Shows the block as the struture bellow
  #   <ul id="sort#{number of the box}">
  #     <li class="block_item_box_#{number of the box}" id="block_#{id of block}">
  #     </li>
  #   </ul>
  #      
  def show_blocks(box, main_content = "")
    blocks = box.blocks_sort_by_position
    content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, b.main? ? main_content : b.to_html, :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}" )
      }, :id => "sort_#{box.number}"
    ) 
  end

  # Shows the blocks as defined in <tt>show_blocks</tt> adding the sortable and draggable elements.
  # In this case the layout can be manipulated
  def edit_blocks(box, main_content = "")
    blocks = box.blocks_sort_by_position
    content_tag(:ul, 
      blocks.map {|b| 
       content_tag(:li, b.main? ? main_content : b.to_html , :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}" ) + draggable("block_#{b.id}")
      }, :id => "sort_#{box.number}"
    ) + drag_drop_items(box) + sortable_block(box.number)
  end

  # Allows the biven box to have sortable elements
  def sortable_block(box_number)
    sortable_element "sort_#{box_number}",
    :url => {:action => 'sort_box', :box_number => box_number },
    :complete => visual_effect(:highlight, "sort_#{box_number}")
  end

  # Allows an element item to be draggable
  def draggable(item)
    draggable_element(item, :ghosting=>true, :revert=>true)
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
