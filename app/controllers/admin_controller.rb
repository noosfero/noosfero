class AdminController < ApplicationController

  before_action :login_required
  before_action :require_env_admin

  private

  def require_env_admin
    unless current_person && current_person.in?(environment.admins)
      render_access_denied
    end
  end

end
