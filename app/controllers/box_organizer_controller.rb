class BoxOrganizerController < ApplicationController

  before_filter :login_required

  def index
    @available_blocks = available_blocks.uniq.sort_by(&:pretty_name)
  end

  def move_block
    @block = params[:id] ? boxes_holder.blocks.find(params[:id].gsub(/^block-/, '')) : nil

    target_position = nil

    if (params[:target] =~ /before-block-([0-9]+)/)
      block_before = boxes_holder.blocks.find($1)
      target_position = block_before.position

      @target_box = block_before.box
    elsif params[:target] =~ /end-of-box-([0-9]+)/

      @target_box = boxes_holder.boxes.find_by id: $1
    end

    @block = new_block(params[:type], @target_box) if @block.nil?
    @source_box = @block.box

    if (@source_box != @target_box)
      @block.remove_from_list
      @block.box = @target_box
    end

    if target_position.nil?
      # insert in the end of the box
      @block.insert_at(@target_box.blocks.size + 1)
      @block.move_to_bottom
    else
      new_position = if @block.position and @block.position < target_position then target_position - 1 else target_position end
      @block.insert_at new_position
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

  def edit
    @block = boxes_holder.blocks.find(params[:id])
    render :action => 'edit', :layout => false
  end

  def search_autocomplete
    if request.xhr? and params[:query]
      search = params[:query]
      path_list = if boxes_holder.is_a?(Environment) && boxes_holder.enabled?('use_portal_community') && boxes_holder.portal_community
                    boxes_holder.portal_community.articles.where("name ILIKE ? OR path ILIKE ?", "%#{search}%", "%#{search}%").limit(20).map { |content| "/{portal}/"+content.path }
      elsif boxes_holder.is_a?(Profile)
        boxes_holder.articles.where("name ILIKE ? OR path ILIKE ?", "%#{search}%", "%#{search}%").limit(20).map { |content| "/{profile}/"+content.path }
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
    return render_access_denied unless @block.editable?(user)
    @block.update(params[:block])
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

  def show_block_type_info
    type = params[:type]
    if type.blank? || !available_blocks.map(&:name).include?(type)
      raise ArgumentError.new("Type %s is not allowed. Go away." % type)
    end
    @block = type.constantize.new
    @block.box = Box.new(:owner => boxes_holder)
    render :action => 'show_block_type_info', :layout => false
  end

  protected :boxes_editor?

  protected

  def new_block(type, box)
    if !available_blocks.map(&:name).include?(type)
      raise ArgumentError.new("Type %s is not allowed. Go away." % type)
    end
    block = type.constantize.new
    box.blocks << block
    block
  end

end
