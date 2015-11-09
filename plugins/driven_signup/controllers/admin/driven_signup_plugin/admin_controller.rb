class DrivenSignupPlugin::AdminController < AdminController

  no_design_blocks

  protect 'edit_environment_features', :environment

  def index

  end

  def new
    @auth = environment.driven_signup_auths.build
  end

  def edit
    @auth = environment.driven_signup_auths.where(id: params[:id]).first
    @auth ||= environment.driven_signup_auths.build
    @auth.update params[:auth]
  end

  def destroy
    @auth = environment.driven_signup_auths.where(token: params[:token]).first
    @auth.destroy if @auth
  end

end
