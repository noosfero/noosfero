# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :detect_stuff_by_domain

  #TODO See a better way to do this. The layout need a owner to work
  before_filter :load_owner
  def load_owner
    @owner = User.find(1)
  end

  #TODO See a better way to do this. We need that something say to us when is the time to edit the layout.
  #I think the better way is set a different render class to the visualization and to edit a layout.
  before_filter :detect_edit_layout
  def detect_edit_layout
    @edit_layout = true unless params[:edit_layout].nil?
  end

  # This method changes a block content to a different box place and
  # updates all boxes at the ends
  def change_box
    b = Block.find(params[:block])
    b.box = Box.find(params[:box_id])
    b.save
    render :update do |page| 
      @owner.boxes.each do |box|
        @box_number = box.number
        page.replace_html "box_#{box.number}", {:partial => 'layouts/box_template'}
        page.sortable "leo_#{box.number}", :url => {:action => 'sort_box', :box_number => box.number}
      end
    end
  end

  def sort_box
    blocks = Array.new
    box_number = params[:box_number]
    pos = 0
    params["leo_#{box_number}"].each do |block_id|
      pos = pos + 1
      b = Block.find(block_id)
      b.position = pos
      b.save
      blocks.push(b)
    end
    @box_number = box_number
    render :partial => 'layouts/box_template'
  end

  protected

  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @virtual_community = VirtualCommunity.default
    else
      @virtual_community = @domain.virtual_community
      @profile = @domain.profile
    end
  end

end
