# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :detect_stuff_by_domain

  protected

  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    @virtual_community = @domain.virtual_community
    @profile = @domain.profile
  end

end
