class BoxOrganizerController < ApplicationController

  before_filter :login_required

  def index
  end

  def move_block
    @block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ''))

    @source_box = @block.box

    target_position = nil

    if (params[:target] =~ /before-block-([0-9]+)/)
      block_before = boxes_holder.blocks.find($1)
      target_position = block_before.position

      @target_box = block_before.box
    else
      (params[:target] =~ /end-of-box-([0-9]+)/)

      @target_box = boxes_holder.boxes.find($1)
    end

    if (@source_box != @target_box)
      @block.remove_from_list
      @block.box = @target_box
    end

    if target_position.nil?
      # insert in the end of the box
      @block.insert_at(@target_box.blocks.size + 1)
      @block.move_to_bottom
    else
      # insert the block in the given position
      @block.insert_at(@block.position && @block.position < target_position ? target_position - 1 : target_position)
    end

    @block.save!

    @target_box.reload

    unless request.xhr?
      redirect_to :action => 'index'
    end
  end

  def move_block_down
    @block = boxes_holder.blocks.find(params[:id])
    @block.move_lower
    redirect_to :action => 'index'
  end

  def move_block_up
    @block = boxes_holder.blocks.find(params[:id])
    @block.move_higher
    redirect_to :action => 'index'
  end

  def add_block
    type = params[:type]
    if ! type.blank?
      if available_blocks.map(&:name).include?(type)
        boxes_holder.boxes.find(params[:box_id]).blocks << type.constantize.new
        redirect_to :action => 'index'
      else
        raise ArgumentError.new("Type %s is not allowed. Go away." % type)
      end
    else
      @center_block_types = (Box.acceptable_center_blocks & available_blocks) + plugins.dispatch(:extra_blocks, :type => boxes_holder.class, :position => 1)
      @side_block_types = (Box.acceptable_side_blocks & available_blocks) + plugins.dispatch(:extra_blocks, :type => boxes_holder.class, :position => [2,3])
      @boxes = boxes_holder.boxes.with_position
      render :action => 'add_block', :layout => false
    end
  end

  def edit
    @block = boxes_holder.blocks.find(params[:id])
    render :action => 'edit', :layout => false
  end

  def search_autocomplete
    if request.xhr? and params[:query]
      search = params[:query]
      path_list = if boxes_holder.is_a?(Environment) && boxes_holder.enabled?('use_portal_community') && boxes_holder.portal_community
        boxes_holder.portal_community.articles.find(:all, :conditions=>"name ILIKE '%#{search}%' or path ILIKE '%#{search}%'", :limit=>20).map { |content| "/{portal}/"+content.path }
      elsif boxes_holder.is_a?(Profile)
        boxes_holder.articles.find(:all, :conditions=>"name ILIKE '%#{search}%' or path ILIKE '%#{search}%'", :limit=>20).map { |content| "/{profile}/"+content.path }
      else
        []
      end
      render :json => path_list.to_json
    else
      redirect_to "/"
    end
  end

  def save
    @block = boxes_holder.blocks.find(params[:id])
    @block.update_attributes(params[:block])
    redirect_to :action => 'index'
  end

  def boxes_editor?
    true
  end

  def remove
    @block = Block.find(params[:id])
    if @block.destroy
      redirect_to :action => 'index'
    else
      session[:notice] = _('Failed to remove block')
    end
  end

  def clone_block
    block = Block.find(params[:id])
    block.duplicate
    redirect_to :action => 'index'
  end

  protected :boxes_editor?

end
