# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :detect_stuff_by_domain

  before_filter :detect_edit_layout

  def detect_edit_layout
    @edit_layout = true unless params[:edit_layout].nil?
  end

#  after_filter :render_actions

  def render_actions
@bla = 'funfou'
#return @bla
       render_action('index', nil, true)
#    render :update do |page|
#      page.replace_html 'box_1', :partial => 'pending_todos'
#      page.replace_html 'completed_todos', :partial => 'completed_todos'
#      page.replace_html 'working_todos', :partial => 'working_todos'
#    end
  end

# def render(type = nil) 
#   render_actions
# end

  protected

  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @virtual_community = VirtualCommunity.default
    else
      @virtual_community = @domain.virtual_community
      @profile = @domain.profile
    end
  end

end
