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

end
