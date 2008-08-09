class ThemesController < MyProfileController

  no_design_blocks

  def set
    profile.update_attributes!(:theme => params[:id])
    redirect_to :action => 'index'
  end

  def index
    @themes = Theme.system_themes
    @selected_theme = profile.theme
  end

end
