class EditTemplateController < ApplicationController

  # TODO: this methods don't belong here
  #TODO See a better way to do this. The layout need a owner to work
#  before_filter :load_owner
#  def load_owner
#  end

#  before_filter :load_boxes
  def load_boxes
    @owner = User.find(1)
    @boxes = @owner.boxes
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
        page.sortable "sort_#{box.number}", :url => {:action => 'sort_box', :box_number => box.number}
      end
    end
  end

  def sort_box
    blocks = Array.new
    box_number = params[:box_number]
    pos = 0
    params["sort_#{box_number}"].each do |block_id|
      pos = pos + 1
      b = Block.find(block_id)
      b.position = pos
      b.save
      blocks.push(b)
    end
    @box_number = box_number
    render :partial => 'layouts/box_template'
  end

end
