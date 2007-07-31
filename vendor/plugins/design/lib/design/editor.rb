module Design

  # This module contains the functionality for e design editor.
  #
  # FIXME: this helper module is still deeply broken, with code just copied
  # from flexible_template
  module Editor

    def design_editor

      if request.post?
        design_editor_set_template
        design_editor_set_theme
        design_editor_set_icon_theme

        if self.class.design_plugin_config[:autosave] && design.respond_to?(:save)
          design.save
        end

        if request.xhr?
          render :text => 'ok'
        else
          redirect_to :action => 'design_editor'
        end

      else
        render :action => 'design_editor'
      end
    end

    # TODO: see below here
  
    def design_editor_set_sort_mode
      box = design.boxes.find(params[:box_id])
      render :update do |page|
        page.replace_html "box_#{box.number}",  edit_blocks(box)
        page.sortable "sort_#{box.number}", :url => {:action => 'design_editor_sort_box', :box_number => box.number}
      end
    end
  
    def design_editor_sort_box
      box_number = params[:box_number]
      pos = 0
      params["sort_#{box_number}"].each do |block_id|
        pos = pos + 1
  #TO this is a security fail we have to limit the researh only in valid blocks of owners
        b = Block.find(block_id)
        b.position = pos
        b.save
      end
    end
  
    # This method changes a block content to a different box place and
    # updates all boxes at the ends
    def design_editor_change_box
      #TODO fix it i tried the source code comment but i have no success
      #b = design.blocks.detect{|b| b.id.to_s == params[:block].to_s }
      b =  Block.find(params[:block])
      b.box = design.boxes.find(params[:box_id])
      b.save
      render :update do |page|
        design.boxes.each do |box|
          page.replace_html "box_#{box.number}", edit_blocks(box)
        end
      end
    end
  
    def design_editor_new_block
      box = design.boxes.find(params[:box_id])
      render :update do |page|
        page.replace_html "box_#{box.number}", design_editor_new_block_form(box)
      end
    end
  
    def design_editor_create_block
      block = Block.new(params[:block])
      block.box = nil if !@ft_config[:boxes].include? block.box
      block.position = block.box.blocks.count + 1 if !block.box.nil?
      if block.save
        render :update do |page|
          page.replace_html "box_#{block.box.number}",  edit_blocks(block.box)
        end
      else
        render :update do |page|
          page.replace_html "design_editor_edit_mode",  _('Block cannot be saved')
        end
      end
    end
  
    def design_editor_destroy_block
      block = Block.find(params[:block_id])
      box = block.box
  #TO check if the block is of the owner
      block.destroy
      render :update do |page|
        page.replace_html "box_#{box.number}",  edit_blocks(box)
      end
    end
  
    private
  
  
    #Load a set of boxes belongs to a owner. We have to situations.
    #  1 - The owner has equal or more boxes that boxes defined in template.
    #      The system limit the max number of boxes to the number permited in template
    #  2 - The owner there isn't enough box that defined in template
    #      The system create the boxes needed to use the current template
    #If no chosen_template was selected the default template is set
    def ft_load_boxes
      n = boxes_by_template(@ft_config[:template])
      boxes = design.boxes 
  
      if boxes.length >= n
        boxes = boxes.first(n)
      else
        while boxes.length < n do
          b = Box.new
          b.owner = design
          raise _('The box cannot be saved becaus of erros %s') % b.errors if !b.save
          boxes.push(b)
        end
      end
      boxes
    end
  
    # Return the number of boxes defined in template file.
    # If the template file didn't exist the default template is loaded
    def boxes_by_template(template)
      template_def_file = Dir.glob("#{RAILS_ROOT}/public/templates/#{template}/*.yml")
  
      if  template_def_file.length != 1
        flash[:notice] = _("The template %s is not a valid template. You don't have the %s.yml file or there are more than one yml file to define your template") % [template, template]
        return
      end
  
      f = YAML.load_file(template_def_file.to_s)
      number_of_boxes = f[template.to_s]["number_of_boxes"]
      flash[:notice] = _("The file #{@ft_config[:template]}.yml it's not a valid template filename") if number_of_boxes.nil?
      number_of_boxes
    end

    private

    def exists_template?(template)
      Design.available_templates.include?(template)
    end
  
    def exists_theme?(theme)
      Design.available_themes.include?(theme)
    end
  
    def exists_icon_theme?(icon_theme)
      Design.available_icon_themes.include?(icon_theme)
    end

    # Set to the owner the template choosed
    def design_editor_set_template
      if exists_template?(params[:template])
        design.template = params[:template]
      end
    end

    # Set to the owner the theme choosed
    def design_editor_set_theme
      if exists_theme?(params[:theme])
        design.theme = params[:theme]
      end
    end

    # Set to the owner the icon_theme choosed
    def design_editor_set_icon_theme
      if request.post? && exists_icon_theme?(params[:icon_theme])
        design.icon_theme = params[:icon_theme]
      end
    end


  end

end
