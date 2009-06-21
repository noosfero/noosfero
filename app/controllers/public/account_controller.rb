class AccountController < ApplicationController

  inverse_captcha :field => 'e_mail'

  require_ssl :except => [ :login_popup, :logout_popup, :wizard, :profile_details ]

  # say something nice, you goof!  something sweet.
  def index
    unless logged_in?
      render :action => 'index_anonymous'
    end
  end

  # action to perform login to the application
  def login
    @user = User.new
    @person = @user.build_person
    return unless request.post?
    self.current_user = User.authenticate(params[:user][:login], params[:user][:password]) if params[:user]
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      go_to_user_initial_page if redirect?
      flash[:notice] = _("Logged in successfully") if redirect?
    else
      flash[:notice] = _('Incorrect username or password') if redirect?
      redirect_to :back if redirect?
    end
  end

  def logout_popup
    render :action => 'logout_popup', :layout => false
  end

  def login_popup
    @user = User.new
    render :action => 'login', :layout => false
  end

  # action to register an user to the application
  def signup
    @invitation_code = params[:invitation_code]
    @wizard = params[:wizard].blank? ? false : params[:wizard]
    @step = 1
    begin
      @user = User.new(params[:user])
      @user.terms_of_use = environment.terms_of_use
      @user.environment = environment
      @terms_of_use = environment.terms_of_use
      @person = Person.new(params[:profile_data])
      @person.name = @user.login
      @person.environment = @user.environment
      if request.post? && params[self.icaptcha_field].blank?
        @user.signup!
        self.current_user = @user
        owner_role = Role.find_by_name('owner')
        @user.person.affiliate(@user.person, [owner_role]) if owner_role
        invitation = Task.find_by_code(@invitation_code)
        if invitation
          invitation.update_attributes!({:friend => @user.person})
          invitation.finish
        end
        flash[:notice] = _("Thanks for signing up!")
        if @wizard
          redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
          return
        else
          go_to_user_initial_page if redirect?
        end
      end
    if @wizard
      render :layout => 'wizard'
    end
    rescue ActiveRecord::RecordInvalid
      @person.valid?
      if @wizard
        render :action => 'signup', :layout => 'wizard'
      else
        render :action => 'signup'
      end
    end
  end

  def wizard
    render :layout => false
  end

  def profile_details
    @profile = Profile.find_by_identifier(params[:profile])
    render :partial => 'profile_details', :layout => 'wizard'
  end

  # action to perform logout from the application
  def logout
    if logged_in?
      self.current_user.forget_me
    end
    cookies.delete :auth_token
    reset_session
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default(:controller => 'account', :action => 'index')
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

  def activation_question
    @enterprise = load_enterprise
    unless @enterprise
      render :action => 'invalid_enterprise_code'
      return
    end
    if @enterprise.enabled
      render :action => 'already_activated'
      return
    end

    @question = @enterprise.question
    if !@question || @enterprise.blocked?
      render :action => 'blocked'
      return
    end
  end

  def accept_terms
    @enterprise = load_enterprise
    @question = @enterprise.question

    if @enterprise.enabled
      render :action => 'already_activated'
      return
    end

    @question = @enterprise.question
    if !@question || @enterprise.blocked?
      render :action => 'blocked'
      return
    end
  end

  def accept_terms
    @enterprise = load_enterprise
    @question = @enterprise.question
    if !@question || @enterprise.blocked?
      render :action => 'blocked'
      return
    end

    check_answer
    @terms_of_enterprise_use = environment.terms_of_enterprise_use
  end

  def activate_enterprise
    @terms_of_use = environment.terms_of_use
    @enterprise = load_enterprise
    @question = @enterprise.question
    return unless check_answer
    return unless check_acceptance_of_terms
    load_user
    
    activation = load_enterprise_activation
    if activation && user
      activation.requestor = user
      activation.finish
      redirect_to :action => 'welcome', :enterprise => @enterprise.id
    end
  end

  def welcome
    @enterprise = Enterprise.find(params[:enterprise])
    unless @enterprise.enabled? && logged_in?
      redirect_to :action => 'index'
    end
  end

  def check_url
    @identifier = params[:identifier]
    valid = Person.is_available?(@identifier)
    if valid
      @status = _('Available!')
      @status_class = 'available'
    else
      @status = _('Unavailable!')
      @status_class = 'unavailable'
    end
    @url = environment.top_url + '/' + @identifier
    render :partial => 'identifier_status'
  end

  protected

  def redirect?
    !@cannot_redirect
  end

  def no_redirect
    @cannot_redirect = true
  end
  
  def load_user
    unless logged_in?
      no_redirect
      if params[:new_user]
        signup
      else
        login
      end
    end
    true
  end

  def check_answer
    unless answer_correct
      @enterprise.block
      render :action => 'blocked'
      return
    end
    true
  end

  def check_acceptance_of_terms
    unless params[:terms_accepted]
      redirect_to :action => 'index'
      return
    end
    true
  end

  def load_enterprise_activation
    @enterprise_activation ||= EnterpriseActivation.find_by_code(params[:enterprise_code])
  end

  def load_enterprise
    activation = load_enterprise_activation
    if activation.nil?
      nil
    else
      activation.enterprise
    end
  end

  def answer_correct
    return true unless params[:enterprise_code]

    enterprise = load_enterprise
    return false unless enterprise.question
    return false if enterprise.enabled

    params[:answer] == enterprise.send(enterprise.question).to_s
  end

  def go_to_user_initial_page
    if environment == current_user.environment
      redirect_back_or_default(user.admin_url)
    else
      redirect_back_or_default(:controller => 'home')
    end
  end

end
