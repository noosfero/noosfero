class PublicController < ApplicationController

  def urls_to_cache
    assets = [
      'application.css',
      'application.js',
      'designs/themes/base/style.css',
      template_stylesheet_path,
      theme_stylesheet_path,
      icon_theme_stylesheet_path
    ].flatten.map{ |f| ActionController::Base.helpers.asset_path(f) }

    urls = [Noosfero.root('/'), '/offline'] + assets
    urls += plugins.dispatch(:cache_urls)
    render plain: urls.flatten.to_json
  end

  def offline
    @no_design_blocks = true
  end

  protected

  def allow_access_to_page
    unless profile.display_to?(user)
      if profile.secret
        invisible_profile
      else
        private_profile
      end
    end
  end

  def private_profile
    private_profile_partial_parameters
    render :template => 'profile/_private_profile', :status => 403, :formats => [:html]
  end

  def invisible_profile
    unless profile.is_template?
      render_access_denied(_("This profile is inaccessible. You don't have the permission to view the content here."), _("Oops ... you cannot go ahead here"))
    end
  end
end
