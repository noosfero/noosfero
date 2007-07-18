class TestController < ApplicationController
  def index
    render :text => 'index'
  end

  post_only 'post_only'
  def post_only
    render :text => '<span>post_only</span>'
  end
end
