# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def show_block(owner,box_number)
    blocks = owner.boxes.find(:first, :conditions => ['number = ?', box_number]).blocks
    @out = blocks.map {|b| b.to_html}.join('')
  end

end
