module Design

  module Helper

    # proxies calls to controller's design method to get the design information
    # holder object
    def design
      @controller.send(:design)
    end

    ########################################################
    # Boxes and Blocks related
    ########################################################

    # Displays +content+ inside the design used by the controller. Normally
    # you'll want use this method in your layout view, like this:
    #
    #   <%= design_display(yield) %>
    #
    # +content+ will be put inside all the blocks which return +true+ in the
    # Block.main? method.
    #
    # The number of boxes generated will be no larger than the maximum number
    # supported by the template, which is indicated in its YAML description
    # file.
    #
    # If not blocks are present (e.g. the design holder has no blocks yet),
    # +content+ is returned right away.
    def design_display(content = "")

      # no blocks. nothing to be done
      return content if design.boxes.empty?

      # Generate all boxes of the current profile and considering the defined
      # on template.

      design.boxes.map do |box|
        content_tag(:div, design_display_blocks(box, content) , :id=>"box_#{box.number}")
      end.join("\n")
    end

    # Displays all the blocks in a box.
    #   <ul id="sort#{number of the box}">
    #     <li class="block_item_box_#{number of the box}" id="block_#{id of block}">
    #     </li>
    #   </ul>
    #
    def design_display_blocks(box, content = "")
      blocks = box.blocks_sort_by_position
      blocks.map do |block|
        # FIXME: should that actually be list_content?
        text = block.main? ? content : design_block_content(block)
        content_tag(:div, text, :class => "block" , :id => "block_#{block.id}" )
      end.join("\n")
    end

    # Displays the content of a block. See plugin README for details about the
    # possibilities.
    def design_block_content(block)
      content = block.content
      case content
      when Proc
        self.instance_eval(&content)
      when Array
        content_tag(
          'ul',
          content.map do |c|
            content_tag(
            'li',
            c
            )
          end
        )
      else
        content.to_s
      end
    end

    # TODO: test stuff below this comment

    ########################################################
    # Template
    ########################################################
    # Load all the javascript files of a existing template with the template_name passed as argument.
    #
    # The files loaded are in the path:
    #
    # 'public/templates/#{template_name}/javascripts/*'
    #
    # If a invalid template it's passed the default template is applied
    def javascript_include_tag_for_template
      template_javascript_dir = Dir.glob("#{RAILS_ROOT}/public/templates/#{@ft_config[:template]}/javascripts/*.js")

      return if template_javascript_dir.blank?

      parse_path(template_javascript_dir).map do |filename|
        javascript_include_tag(filename)
      end
    end

    # Load all the css files of a existing template with the template_name passed as argument.
    #
    # The files loaded are in the path:
    #
    # 'public/templates/#{template_name}/stylesheets/*'
    # If a invalid template it's passed the default template is applied
    def stylesheet_link_tag_for_template
      template_stylesheet_dir = Dir.glob("#{RAILS_ROOT}/public/templates/#{@ft_config[:template]}/stylesheets/*.css")

      if template_stylesheet_dir.blank?
        flash[:notice] = _("There is no stylesheets in directory %s of template %s.") % [ template_stylesheet_dir, @ft_config[:template]]
        return
      end

      parse_path(template_stylesheet_dir).map do |filename|
        stylesheet_link_tag(filename)
      end
    end


    #################################################
    #THEMES 
    #################################################

    # Load all the css files of a existing theme with the @ft_config[:theme] passed as argument in owner object.
    #
    # The files loaded are in the path:
    #
    # 'public/themes/#{theme_name}/*'
    # If a invalid theme it's passed the 'default' theme is applied
    def stylesheet_link_tag_for_theme
      path = "#{RAILS_ROOT}/public/themes/#{@ft_config[:theme]}/"
      theme_dir = Dir.glob(path+"*")

      return if theme_dir.blank?

      parse_path(theme_dir).map do |filename|
        stylesheet_link_tag(filename)
      end

    end


    #Display a given icon passed as argument
    #The icon path should be '/icons/{icon_theme}/{icon_image}'
    def display_icon(icon, options = {})
      image_tag("/icons/#{@ft_config[:icon_theme]}/#{icon}.png", options)
    end

    private
 

    # Check if the current controller is the controller that allows layout editing
    def edit_mode?
      controller.flexible_template_edit_template?
    end 

    def parse_path(files_path = [], remove_until = 'public')
      remove_until = remove_until.gsub(/\//, '\/')
      files_path.map{|f| f.gsub(/.*#{remove_until}/, '')}
    end

  end # END OF module Helper

end #END OF module Design
