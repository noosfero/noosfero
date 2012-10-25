class NotFoundController < ApplicationController
  def index
    render_not_found
  end

  def nothing
    render :nothing => true, :status => 404
  end
end
