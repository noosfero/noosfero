class EmbedController < ApplicationController
  layout 'embed'

  def block
    @block = Block.find(params[:id])
    if !@block.embedable? || !@block.visible?
      render 'unavailable', :status => 403
    end
    rescue ActiveRecord::RecordNotFound
      render 'not_found', :status => 404
  end

end
