class EmbedController < ApplicationController
  layout 'embed'

  def block
    @block = Block.find(params[:id])
    if !@block.embedable? || !@block.visible?
      render 'unavailable.rhtml', :status => 403
    end
    rescue ActiveRecord::RecordNotFound
      render 'not_found.rhtml', :status => 404
  end

end
