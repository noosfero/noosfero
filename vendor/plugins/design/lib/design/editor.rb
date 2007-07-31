module Design

  # This module contains the functionality for e design editor.
  #
  # FIXME: this helper module is still deeply broken, with code just copied
  # from flexible_template
  module Editor

    #FIXME: move extraction of these values elsewhere
    def start
      @ft_config[:available_templates] = parse_path(Dir.glob("#{RAILS_ROOT}/public/templates/*"), 'templates/')
      @ft_config[:available_themes] = parse_path(Dir.glob("#{RAILS_ROOT}/public/themes/*"), 'themes/')
      @ft_config[:available_icon_themes] = parse_path(Dir.glob("#{RAILS_ROOT}/public/icons/*"), 'icons/')
    end
  
    def flexible_template_edit_template?
      @ft_config[:edit_mode] 
    end
  
    # Set the default template to the profile
    def set_default_template
      set_template(@ft_config[:owner],params[:template_name]) if exist_template? params[:template_name]
    end
  
    # Set the default theme to the profile
    def set_default_theme
      set_theme(@ft_config[:owner],params[:theme_name]) if exist_theme? params[:theme_name]
    end
  
    # Set the default icons theme to the profile
    def set_default_icon_theme
      set_icon_theme(@ft_config[:owner],params[:icon_theme_name]) if exist_icon_theme? params[:icon_theme_name]
    end
  
    def flexible_template_set_sort_mode
      box = @ft_config[:owner].boxes.find(params[:box_id])
      render :update do |page|
        page.replace_html "box_#{box.number}",  edit_blocks(box)
        page.sortable "sort_#{box.number}", :url => {:action => 'flexible_template_sort_box', :box_number => box.number}
      end
    end
  
    def flexible_template_sort_box
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
    def flexible_template_change_box
      #TODO fix it i tried the source code comment but i have no success
      #b = @ft_config[:owner].blocks.detect{|b| b.id.to_s == params[:block].to_s }
      b =  Block.find(params[:block])
      b.box = @ft_config[:owner].boxes.find(params[:box_id])
      b.save
      render :update do |page|
        @ft_config[:owner].boxes.each do |box|
          page.replace_html "box_#{box.number}", edit_blocks(box)
        end
      end
    end
  
    def flexible_template_new_block
      box = @ft_config[:owner].boxes.find(params[:box_id])
      render :update do |page|
        page.replace_html "box_#{box.number}", new_block_form(box)
      end
    end
  
    def flexible_template_create_block
      block = Block.new(params[:block])
      block.box = nil if !@ft_config[:boxes].include? block.box
      block.position = block.box.blocks.count + 1 if !block.box.nil?
      if block.save
        render :update do |page|
          page.replace_html "box_#{block.box.number}",  edit_blocks(block.box)
        end
      else
        render :update do |page|
          page.replace_html "flexible_template_edit_mode",  _('Block cannot be saved')
        end
      end
    end
  
    def flexible_template_destroy_block
      block = Block.find(params[:block_id])
      box = block.box
  #TO check if the block is of the owner
      block.destroy
      render :update do |page|
        page.replace_html "box_#{box.number}",  edit_blocks(box)
      end
    end
  
    private
  
    # Set to the owner the theme choosed
    def set_theme(object, theme_name)
      object.flexible_template_theme = theme_name
      object.save
    end
  
    # Set to the owner the icons theme choosed
    def set_icon_theme(object,icon_theme_name)
      object.flexible_template_icon_theme = icon_theme_name
      object.save
    end
  
    # Set to the owner the template choosed
    def set_template(object, template_name)
      object.flexible_template_template = template_name
      object.save
    end
  
    #Load a set of boxes belongs to a owner. We have to situations.
    #  1 - The owner has equal or more boxes that boxes defined in template.
    #      The system limit the max number of boxes to the number permited in template
    #  2 - The owner there isn't enough box that defined in template
    #      The system create the boxes needed to use the current template
    #If no chosen_template was selected the default template is set
    def ft_load_boxes
      n = boxes_by_template(@ft_config[:template])
      boxes = @ft_config[:owner].boxes 
  
      if boxes.length >= n
        boxes = boxes.first(n)
      else
        while boxes.length < n do
          b = Box.new
          b.owner = @ft_config[:owner]
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
  
    def exist_template? template
      @ft_config[:available_templates].include?(template)
    end
  
    def exist_theme? theme
      @ft_config[:available_themes].include?(theme)
    end
  
    def exist_icon_theme? icon_theme
      @ft_config[:available_icon_themes].include?(icon_theme)
    end
  
    def parse_path(files_path = [], remove_until = 'public')
      remove_until = remove_until.gsub(/\//, '\/')
      files_path.map{|f| f.gsub(/.*#{remove_until}/, '')}
    end

  end

end
