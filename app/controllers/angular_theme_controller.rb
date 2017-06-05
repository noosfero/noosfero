class AngularThemeController < ApplicationController
  needs_profile
  before_filter :verify_angular_theme

  def index
    render_not_found
  end

  def verify_angular_theme
    render 'home/index' if Theme.angular_theme?(current_theme) && !request.path.starts_with?('/api/')
  end
end
