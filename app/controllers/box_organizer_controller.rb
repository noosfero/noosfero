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
      @block_types = available_blocks
      @boxes = boxes_holder.boxes
      render :action => 'add_block', :layout => false
    end
  end

  def edit
    @block = boxes_holder.blocks.find(params[:id])
    render :action => 'edit', :layout => false
  end

  def save
    @block = boxes_holder.blocks.find(params[:id])
    @block.update_attributes(params[:block])
    expire_timeout_fragment(@block.cache_keys)
    redirect_to :action => 'index'
  end

  def boxes_editor?
    true
  end

  def remove
    @block = Block.find(params[:id])
    if @block.destroy
      expire_timeout_fragment(@block.cache_keys)
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Failed to remove block')
    end
  end

  def toggle_visibility
    @block = boxes_holder.blocks.find(params[:id])
    @block.visible = !@block.visible?
    @block.save
    redirect_to :action => 'index'
  end

  protected :boxes_editor?

end
