class EmbedController < ApplicationController
  layout 'embed'

  def block
    @block = Block.find(params[:id])
    @source = params[:source]
    if !@block.embedable? || !@block.visible?
      render :template => 'shared/embed_unavailable.rhtml', :status => 403
    end
    rescue ActiveRecord::RecordNotFound
      render :template => 'shared/embed_not_found.rhtml', :status => 404
  end

end
