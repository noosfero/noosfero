class ProfileDesignController < BoxOrganizerController

  needs_profile

  def available_blocks
    @available_blocks ||= [ Block, ArticleBlock ]
  end

  def index
    render :action => 'index'
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

  def boxes_editor?
    true
  end
  protected :boxes_editor?

end
