class AccountController < ApplicationController

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
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = _("Logged in successfully")
    else
      flash[:notice] = _('Incorrect username or password')
    end
  end

  # action to register an user to the application
  def signup
    begin
      @terms_of_use = virtual_community.terms_of_use
      terms_accepted = params[:user] ? params[:user].delete(:terms_accepted) : false
      @user = User.new(params[:user])
      return unless request.post?
      if @terms_of_use and !terms_accepted 
        flash[:notice] = _("You have to accept the terms of service to signup")
        return
      end
      @user.save!
      @user.person.virtual_community = virtual_community
      @user.person.save!
      self.current_user = @user
      redirect_back_or_default(:controller => 'account', :action => 'index')
      flash[:notice] = _("Thanks for signing up!")
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

end
