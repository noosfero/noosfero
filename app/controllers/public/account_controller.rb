class AccountController < PublicController

  # say something nice, you goof!  something sweet.
  def index
    unless logged_in?
      render :action => 'index_anonymous'
    end
  end

  # action to perform login to the application
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
#      redirect_back_or_default(:controller => '/account', :action => 'index')
      redirect_back_or_default(homepage_path(:profile => current_user.login))
      flash[:notice] = _("Logged in successfully")
    else
      flash[:notice] = _('Incorrect username or password')
    end
  end

  # action to register an user to the application
  def signup
    begin
      @user = User.new(params[:user])
      @user.terms_of_use = environment.terms_of_use
      @terms_of_use = environment.terms_of_use

      if request.post?
        @user.save!
        @user.person.environment = environment
        @user.person.save!
        self.current_user = @user
        redirect_back_or_default(homepage_path(:profile => current_user.login))
        flash[:notice] = _("Thanks for signing up!")
      end
    rescue ActiveRecord::RecordInvalid
      render :action => 'signup'
    end
  end
  
  # action to perform logout from the application
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  def change_password
    if request.post?
      @user = current_user
      begin 
        @user.change_password!(params[:current_password],
                               params[:new_password],
                               params[:new_password_confirmation])
        flash[:notice] = _('Your password has been changed successfully!')
        redirect_to :action => 'index'
      rescue User::IncorrectPassword => e
        flash[:notice] = _('The supplied current password is incorrect.')
        render :action => 'change_password'
      end
    else
      render :action => 'change_password'
    end
  end

  # The user requests a password change. She forgot her old password.
  #
  # Posts back.
  def forgot_password
    @change_password = ChangePassword.new(params[:change_password])

    if request.post?
      begin
        @change_password.save!
        render :action => 'password_recovery_sent'
      rescue ActiveRecord::RecordInvalid => e
        nil # just pass and render at the end of the action
      end
    end
  end

  # The user has a code for a ChangePassword request object.
  #
  # Posts back.
  def new_password
    @change_password = ChangePassword.find_by_code(params[:code])

    unless @change_password
      render :action => 'invalid_change_password_code', :status => 403
      return
    end

    if request.post?
      begin
        @change_password.update_attributes!(params[:change_password])
        @change_password.finish
        render :action => 'new_password_ok'
      rescue ActiveRecord::RecordInvalid => e
        nil # just render new_password
      end
    end
  end

  protected

  before_filter :load_profile_for_user
  def load_profile_for_user
    return unless logged_in?
    @profile = current_user.person
  end


end
