class TestController < ApplicationController
  def index
    render :text => 'index'
  end

  post_only 'post_only'
  def post_only
    render :text => '<span>post_only</span>'
  end

  def help
    render :inline => '<% help { %> my_help_message <% } %>'
  end

  def help_textile
    render :inline => '<% help_textile { %> *my_bold_help_message* <% } %>'
  end

end
