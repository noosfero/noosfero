class PublicAccessRestrictionPluginPublicPageController < ProfileController

  no_design_blocks

  def index
    @settings = Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin)
    if current_person || @settings.show_public_page.in?(["0", false])
      redirect_to controller: 'profile', profile: @profile.identifier
    end
  end

end
