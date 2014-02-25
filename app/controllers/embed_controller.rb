class EmbedController < ApplicationController

  def index
    block = Block.find(params[:id])
    source = params[:source]

    if !block.visible?
      render :template => 'shared/embed_denied.rhtml', :status => 403, :layout => "embed"
    else
      locals = {:source => source, :block => block}
      render 'embed/index', :layout => 'embed', :locals => locals
    end

    rescue ActiveRecord::RecordNotFound
      render :template => 'shared/embed_not_found.rhtml', :status => 404, :layout => "embed"
  end
end
