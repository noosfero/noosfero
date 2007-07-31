# his is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  design :holder => 'virtual_community'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :detect_stuff_by_domain
  attr_reader :virtual_community

  before_filter :load_owner
    # Load the owner 
  def load_owner
    # TODO: this should not be hardcoded
    @owner = Profile.find(1) if Profile.exists?(1)
  end

  protected

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @virtual_community = VirtualCommunity.default
    else
      @virtual_community = @domain.virtual_community
      @profile = @domain.profile
    end
  end

  def self.acts_as_virtual_community_admin_controller
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
