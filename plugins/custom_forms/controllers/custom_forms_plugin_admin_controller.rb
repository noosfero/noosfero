class CustomFormsPluginAdminController < AdminController
  def index
    @profiles = environment.profiles.joins(:forms).uniq
  end

  def download_files
  end
end
