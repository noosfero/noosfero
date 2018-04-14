class NotFoundController < ApplicationController
  def index
    render_not_found
  end

  def nothing
    head :ok, :status => 404
  end
end
