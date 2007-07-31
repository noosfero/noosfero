module Design

  module Editor

    # defines helper methods for controllers that use +design_editor+
    #
    # FIXME: this Helper module is still deeply broken, just copied code from
    # flexible_template
    module Helper

      # draws the user interface for the design editor. 
      def design_display_editor(content)

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
         design.boxes.map { |box|
          content_tag(:div, edit_blocks(box, content) , :id=>"box_#{box.number}")
         }].join("\n")

         content = content_tag(:div, content, :id => 'design_editor_edit_mode')
      end

      # Symbol dictionary used on select when we add or edit a block.  This
      # method has the responsability of translate a Block class in a humam
      # name By default the class "MainBlock" has the human name "Main Block".
      # Other classes defined by user are not going to display in a human name
      # format until de method design_editor_block_dict be redefined in a
      # controller by user
      # #TODO define the method
      # design_editor_block_dict if not defined by helper
      #      if !self.public_instance_methods.include? "design_editor_block_dict"
      #        define_method('design_editor_block_dict') do |str|
      #          {
      #            'MainBlock' => _("Main Block")
      #          }[str] || str
      #        end
      #      end 


      # FIXME: WTF?
      def design_editor_block_helper_dict(str)
        {
          'plain_content' => _('Plain Content') ,
          'list_content' => _('List Content')
        }[str] || str
      end


      private 

      ########################################
      # TEMPLATE/THEME/ICON THEME CHANGE BOXES
      ########################################

      # Generate a select option to choose one of the available templates.
      # The available templates are those in 'public/templates'
      def select_template
        available_templates = Design.available_templates

        template_options = options_for_select(available_templates.map{|template| [template, template] }, design.template)
        [ select_tag('template', template_options ),
          change_template].join("\n")
      end

      # Generate a observer to reload a page when a template is selected
      def change_template
        observe_field( 'template',
          :url => {:action => 'design_editor'},
          :with =>"'template=' + escape(value)",
          :complete => "document.location.reload();",
          :method => :post
        )
      end

      # Generate a select option to choose one of the available themes.
      # The available themes are those in 'public/themes'
      def select_theme
        available_themes = Design.available_themes
        theme_options = options_for_select(available_themes.map{|theme| [theme, theme] }, design.theme)
        [ select_tag('theme', theme_options ),
          change_theme].join("\n")
      end

      # Generate a observer to reload a page when a theme is selected
      def change_theme
        observe_field( 'theme',
          :url => {:action => 'design_editor'},
          :with =>"'theme=' + escape(value)",
          :complete => "document.location.reload();",
          :method => :post
        )
      end

      # Generate a select option to choose one of the available icons themes.
      # The available icons themes are those in 'public/icons'
      def select_icon_theme
        available_icon_themes = Design.available_icon_themes
        icon_theme_options = options_for_select(available_icon_themes.map{|icon_theme| [icon_theme, icon_theme] }, design.icon_theme )
        [ select_tag('icon_theme', icon_theme_options ),
          change_icon_theme].join("\n")
      end

      # Generate a observer to reload a page when a icons theme is selected
      def change_icon_theme
        observe_field( 'icon_theme',
          :url => {:action => 'design_editor'},
          :with =>"'icon_theme=' + escape(value)",
          :complete => "document.location.reload();",
          :method => :post
        )
      end



      #################################################
      # TEMPLATES METHODS RELATED
      #################################################

      # Shows the blocks as defined in <tt>show_blocks</tt> adding the sortable and draggable elements.
      # In this case the layout can be manipulated
      def edit_blocks(box, main_content = "")
        blocks = box.blocks_sort_by_position
        [
         content_tag(
          :ul,[ 
          box.name,
          link_to_active_sort(box),
          link_to_add_block(box),
          blocks.map {|b|
            [content_tag(
              :li, 
              b.name + link_to_destroy_block(b),
              :class =>"block_item_box_#{box.number}" , :id => "block_#{b.id}"
            ),
            draggable("block_#{b.id}")].join("\n")
          }.join("\n")].join("\n"), :id => "sort_#{box.number}"
        ), 
        drag_drop_items(box)].join("\n")
      end

      def link_to_active_sort(box)
        link_to_remote(_('Sort'),
          {:update => "sort_#{box.number}", :url => {:action => 'design_editor_set_sort_mode', :box_id => box.id }},
          :class => 'sort_button') 
      end

      def link_to_add_block(box)
        link_to_remote(_('Add Block'),
          {:update => "sort_#{box.number}", :url => {:action => 'design_editor_new_block', :box_id => box.id }},
          :class => 'add_block_button')
      end

      def link_to_destroy_block(block)
        link_to_remote(_('Remove'),
          {:update => "sort_#{block.box.number}", :url => {:action => 'design_editor_destroy_block', :block_id => block.id }},
          :class => 'destroy_block_button')
      end


      # Allows the biven box to have sortable elements
      def sortable_block(box_number)
        sortable_element "sort_#{box_number}",
        :url => {:action => 'design_editor_sort_box', :box_number => box_number },
        :complete => visual_effect(:highlight, "sort_#{box_number}")
      end

      # Allows an element item to be draggable
      def draggable(item)
        draggable_element(item, :ghosting => true, :revert => true)
      end

      # Allows an draggable element change between diferrents boxes
      def drag_drop_items(box)
        boxes = design.boxes.reject{|b| b.id == box.id}

        boxes.map{ |b|
          drop_receiving_element("box_#{box.number}",
            :accept     => "block_item_box_#{b.number}",
            :complete   => "$('spinner').hide();",
            :before     => "$('spinner').show();",
            :hoverclass => 'hover',
            :with       => "'block=' + encodeURIComponent(element.id.split('_').last())",
            :url        => {:action=>:design_editor_change_box, :box_id => box.id})
          }.to_s
      end



      def available_blocks
#TOD  O check if are valids blocks
        h = {
          'MainBlock' => _("Main Block"),
        }
        h.merge!(controller.class::FLEXIBLE_TEMPLATE_AVAILABLE_BLOCKS) if controller.class.constants.include? "FLEXIBLE_TEMPLATE_AVAILABLE_BLOCKS"
        h
      end

      def block_helpers
#TOD  O check if are valids helpers
        h = {
          'plain_content' => _("Plain Content"),
          'list_content' => _("Simple List Content"),
        }
        h.merge!(controller.class::FLEXIBLE_TEMPLATE_BLOCK_HELPER) if controller.class.constants.include? "FLEXIBLE_TEMPLATE_BLOCK_HELPER"
        h
      end

      def design_editor_new_block_form(box)
        type_block_options = options_for_select(available_blocks.collect{|k,v| [v,k] })
        type_block_helper_options = options_for_select(block_helpers.collect{|k,v| [v,k] })
        @block = Block.new
        @block.box = box 

        _("Adding block on %s") % box.name +
        [
          form_remote_tag(:url => {:action => 'design_editor_create_block'}, :update => "sort_#{box.number}"),   
            hidden_field('block', 'box_id'),
            content_tag(
              :p,
              [   
                content_tag(
                  :label, _('Name:')
                ),
                text_field('block', 'name')
              ].join("\n")
            ),
            content_tag(
              :p,
              [   
                content_tag(
                  :label, _('Title:')
                ),
                text_field('block', 'title')
              ].join("\n")
            ),
            content_tag(
              :p,
              [   
                content_tag(
                  :label, _('Type:')
                ),
                select_tag('block[type]', type_block_options)
              ].join("\n")
            ),
            content_tag(
              :p,
              [   
                content_tag(
                  :label, _('Visualization Mode:')
                ),
                select_tag('block[helper]', type_block_helper_options)
              ].join("\n")
            ),
            submit_tag( _('Submit')),
          end_form_tag
        ].join("\n")

      end

      #################################################
      #ICONS THEMES RELATED
      #################################################



    end # END OF module Helper

  end # END OF module Editor

end # END OF module Design
