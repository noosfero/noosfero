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

  def profile
    @profile
  end

  def self.needs_profile
    before_filter :load_profile
    design :holder => 'profile'
  end

  def load_profile
    @profile = Profile.find_by_identifier(params[:profile])
    raise "The profile must be loaded %s" % params[:profile].to_s if @profile.nil?
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
end
