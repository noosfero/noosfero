class BoxOrganizerController < ApplicationController

  def move_block
    @block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ''))

    @source_box = @block.box

    target_position = nil

    if (params[:target] =~ /before-block-([0-9]+)/)
      block_before = boxes_holder.blocks.find($1)
      target_position = block_before.position

      @target_box = block_before.box
    else
      (params[:target] =~ /end-of-box-([0-9])+/)

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
  end

  def move_block_down
    @block = boxes_holder.blocks.find(params[:id])
    @block.move_lower
    redirect_to :back
  end

  def move_block_up
    @block = boxes_holder.blocks.find(params[:id])
    @block.move_higher
    redirect_to :back
  end

end
