class NotFoundController < ApplicationController
  def index
    render_not_found
  end

  def nothing
    head :not_found
  end
end
