class EditTemplateController < ApplicationController

  before_filter :manage_template

  attr_accessor :controller_manage_template

  def manage_template?
    self.controller_manage_template == true ? true : false
  end

  # This method changes a block content to a different box place and
  # updates all boxes at the ends
  def change_box
    b = Block.find(params[:block])
    b.box = Box.find(params[:box_id])
    b.save
    render :update do |page| 
      @boxes.each do |box|
        @box = box
        page.replace_html "box_#{box.number}", {:partial => 'layouts/box_template'}
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
    @box = box_number
    render :partial => 'layouts/box_template'
  end

  def set_sort_mode
    box = Box.find(params[:box_id])
    render :update do |page| 
      @box = box
      page.replace_html "box_#{box.number}", {:partial => 'layouts/box_template'}
      page.sortable "sort_#{box.number}", :url => {:action => 'sort_box', :box_number => box.number}
    end
  end

  private

  def manage_template
    self.controller_manage_template = true
  end

end
