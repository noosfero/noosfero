class ProfileDesignController < BoxOrganizerController
  needs_profile

  protect "edit_profile_design", :profile

  before_action :protect_uneditable_block, only: [:save]
  before_action :protect_fixed_block, only: [:move_block]
  include CategoriesHelper

  def protect_uneditable_block
    block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ""))
    if !current_person.is_admin? && !block.editable?
      render_access_denied
    end
  end

  def protect_fixed_block
    return if params[:id].blank?

    block = boxes_holder.blocks.find(params[:id].gsub(/^block-/, ""))
    if block.present? && !current_person.is_admin? && !block.movable?
      render_access_denied
    end
  end

  def available_blocks
    profile.available_blocks(user)
  end

  def update_categories
    @object = params[:id] ? @profile.blocks.find(params[:id]) : Block.new
    render_categories "block"
  end
end
