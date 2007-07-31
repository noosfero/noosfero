module Design

  module Editor

    # defines helper methods for controllers that use +design_editor+
    module Helper

      # draws the user interface for the design editor. 
      def design_display_editor()
        # TODO: check this
        raise NotImplementedError

        content = [content_tag(
          :ul,[
            content_tag(
            :li,
            select_template,
            :class => 'select_template'
           ),
           content_tag(
             :li,
             select_theme,
             :class => 'select_template'
           ),
           content_tag(
             :li,
             select_icon_theme,
             :class => 'select_template'
           ),
           ].join("\n"),
           :class => 'select_options'
         ), 
         @ft_config[:boxes].map{ |box|
          content_tag(:div, edit_blocks(box, main_content) , :id=>"box_#{box.number}")
         }].join("\n")

         content = content_tag(:div, content, :id => 'flexible_template_edit_mode')
      end

    end # END OF module Helper

  end # END OF module Editor

end # END OF module Design
