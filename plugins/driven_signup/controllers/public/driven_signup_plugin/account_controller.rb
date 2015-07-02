class DrivenSignupPlugin::AccountController < PublicController

  def signup
    return render_access_denied unless Rails.env.development? or request.post?
    return render_access_denied unless self.environment.driven_signup_auths.where(token: params[:token]).first

    session[:driven_signup] = true
    session[:base_organization] = params[:base_organization]
    session[:find_suborganization] = params[:find_suborganization]
    session[:suborganization_members_limit] = params[:suborganization_members_limit]
    session[:user_template] = params[:user_template]

    user_attributes = [:login, :email]
    user_params = params[:signup].slice *user_attributes
    profile_params = params[:signup].except *user_attributes

    if current_user and user_params[:email].squish == current_user.email
      current_user.driven_signup_complete
      redirect_to session.delete(:after_signup_redirect_to)
    else
      self.current_user = nil
      redirect_to controller: :account, action: :signup, user: user_params, profile_data: profile_params
    end
  end

  protected

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

end
