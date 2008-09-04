class TestController < ApplicationController

  def index
    render :text => 'index', :layout => true
  end

  post_only 'post_only'
  def post_only
    render :text => '<span>post_only</span>'
  end

  def help_with_string
    render :inline => '<%= help "my_help_message" %>'
  end

  def help_with_block
    render :inline => '
      <% help do %>
        my_help_message
      <% end %>
    '
  end

  def help_textile_with_string
    render :inline => '<%= help_textile "*my_bold_help_message*" %>'
  end

  def help_textile_with_block
    render :inline => '
      <% help_textile do %>
        *my_bold_help_message*
      <% end %>
    '
  end

  def help_without_block
    render :inline => '
      <% help %>
    '
  end

  require_ssl :only => 'sslonly'
  def sslonly
    render :text => 'this should be seen only on SSL', :layout => false
  end
  def doesnt_need_ssl
    render :text => 'this should be seen even without SSL', :layout => false
  end

  refuse_ssl :only => 'nossl'
  def nossl
    render :text => 'this should not be seen over SSL', :layout => false
  end
  def doesnt_refuse_ssl
    render :text => 'this should be seen over SSL or not, whatever', :layout => false
  end

end
