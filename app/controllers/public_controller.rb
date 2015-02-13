class PublicController < ApplicationController
  protected

  def allow_access_to_page
    unless profile.display_info_to?(user)
      if profile.visible?
        private_profile
      else
        invisible_profile
      end
    end
  end

  def private_profile
    private_profile_partial_parameters
    render :template => 'shared/access_denied.html.erb', :status => 403
  end

  def invisible_profile
    unless profile.is_template?
      render_access_denied(_("This profile is inaccessible. You don't have the permission to view the content here."), _("Oops ... you cannot go ahead here"))
    end
  end
end
