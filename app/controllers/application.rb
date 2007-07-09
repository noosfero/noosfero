# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :detect_stuff_by_domain
  attr_reader :virtual_community

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

  def self.acts_as_admin_controller
    before_filter :load_admin_controller
  end
  def load_admin_controller
    # TODO: check access control
  end

end
