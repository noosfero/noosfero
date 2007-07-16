# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Directories to be rejected of the directories list when needed.
  # TODO I think the better way is create a Dir class method that returns a list of files of a given path
  REJECTED_DIRS = %w[
    .
    ..
    .svn
  ]

  # Generate a select option to choose one of the available templates.
  # The available templates are those in 'public/templates'
  def select_template(object, chosen_template = nil)
    return '' if object.nil?
    available_templates = Dir.new('public/templates').to_a - REJECTED_DIRS
    template_options = options_for_select(available_templates.map{|template| [template, template] }, chosen_template)
    select_tag('template_name', template_options ) +
    change_tempate('template_name', object)
  end

  def change_tempate(observed_field, object)
    observe_field( observed_field,
      :url => {:action => 'set_default_template'},
      :with =>"'template_name=' + escape(value) + '&object_id=' + escape(#{object.id})",
      :complete => "document.location.reload();"
    )
  end

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
    d = Dir.new("public/templates/#{template_name}/stylesheets/").to_a - REJECTED_DIRS 
    d.map do |filename| 
      stylesheet_link_tag("/templates/#{template_name}/stylesheets/#{filename}")
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
    d = Dir.new("public/templates/#{template_name}/javascripts/").to_a - REJECTED_DIRS 
    d.map do |filename| 
      javascript_include_tag("/templates/#{template_name}/javascripts/#{filename}")
    end
  end

  private

  # Check if the current controller is the controller that allows layout editing
  def edit_mode?
    controller.manage_template?
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


end
