class EmbedController < ApplicationController

  def embed_block
    block = Block.find(params[:id])
    source = params[:source]

    if !block.visible?
      render :template => 'shared/embed_denied.rhtml', :status => 403, :layout => "embed-block"
    else
      locals = {:source => source, :block => block}
      render 'embed/index', :layout => 'embed-block', :locals => locals
    end

    rescue ActiveRecord::RecordNotFound
      render :template => 'shared/embed_not_found.rhtml', :status => 404, :layout => "embed-block"
  end
end
