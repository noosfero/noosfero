class PublicAccessRestrictionPluginPageController < MyProfileController

  def index
    @settings = Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin)
  end

  def update
    settings = Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, params[:profile_data])
    if settings.save!
      redirect_to controller: 'profile_editor', action: 'index'
    else
      session[:notice] = _('There was an error while updating the profile data')
      redirect_to action: 'index'
    end
  end

end
