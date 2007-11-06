# his is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  helper :document
  helper :language
  
  design :holder => 'environment'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  extend PermissionCheck
  init_gettext 'noosfero'

  include NeedsProfile

  before_filter :detect_stuff_by_domain
  attr_reader :environment

  def self.acts_as_environment_admin_controller
    before_filter :load_admin_controller
  end

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  protected 

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @environment = Environment.default
    else
      @environment = @domain.environment
      @profile = @domain.profile
    end
  end

  def render_not_found(path)
    @path = path
    render :file => File.join(RAILS_ROOT, 'app', 'views', 'shared', 'not_found.rhtml'), :layout => 'not_found', :status => 404
  end

  def load_admin_controller
    # TODO: check access control
  end

end
