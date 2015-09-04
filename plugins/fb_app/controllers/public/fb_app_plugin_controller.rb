class FbAppPluginController < PublicController

  no_design_blocks

  def index
  end

  def myprofile_config
    if logged_in?
      redirect_to controller: :fb_app_plugin_myprofile, profile: user.identifier
    else
      redirect_to controller: :account, action: :login, return_to: url_for(controller: :fb_app_plugin, action: :myprofile_config)
    end
  end

  protected

  # prevent session reset because X-CSRF not being passed by FB
  # see also https://gist.github.com/toretore/911886
  def handle_unverified_request
  end

end

