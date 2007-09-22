# his is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  helper :document
  
  design :holder => 'environment'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  init_gettext 'noosfero'

  before_filter :detect_stuff_by_domain
  attr_reader :environment

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

  before_filter :load_profile_from_params
  def load_profile_from_params
    if params[:profile]
      @profile ||= Profile.find_by_identifier(params[:profile])
    end
  end

  def profile
    @profile
  end

  def self.acts_as_environment_admin_controller
    before_filter :load_admin_controller
  end
  def load_admin_controller
    # TODO: check access control
  end

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  # Declares the +permission+ need to be able to access +action+.
  #
  # * +action+ must be a symbol or string with the name of the action
  # * +permission+ must be a symbol or string naming the needed permission.
  # * +target+ is the object over witch the user would need the specified permission.
  def self.protect(actions, permission, target = nil)
    before_filter :only => actions do |controller|
      unless controller.send(:logged_in?) and controller.send(:current_user).person.has_permission?(permission, target)
          controller.send(:render, {:file => 'app/views/shared/access_denied.rhtml', :layout => true})
      end
    end
  end
end
