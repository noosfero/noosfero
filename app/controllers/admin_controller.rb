class AdminController < ApplicationController

  before_filter :login_required
  before_filter :require_env_admin

  private

  def require_env_admin
    unless current_person && current_person.in?(environment.admins)
      render_access_denied
    end
  end

end
