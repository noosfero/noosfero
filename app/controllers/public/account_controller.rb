class AccountController < ApplicationController

  no_design_blocks

  before_filter :login_required, :only => [:activation_question, :accept_terms, :activate_enterprise]
  before_filter :redirect_if_logged_in, :only => [:login, :signup]
  before_filter :protect_from_bots, :only => :signup

  # say something nice, you goof!  something sweet.
  def index
    unless logged_in?
      render :action => 'index_anonymous'
    end
  end

  def activate
    @user = User.find_by_activation_code(params[:activation_code]) if params[:activation_code]
    if @user and @user.activate
      @message = _("Your account has been activated, now you can log in!")
      render :action => 'login', :userlogin => @user.login
    else
      session[:notice] = _("It looks like you're trying to activate an account. Perhaps have already activated this account?")
      redirect_to :controller => :home
    end
  end

  # action to perform login to the application
  def login
    store_location(request.referer) unless session[:return_to]
    return unless request.post?

    self.current_user = plugins_alternative_authentication

    self.current_user ||= User.authenticate(params[:user][:login], params[:user][:password], environment) if params[:user]

    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if redirect?
        go_to_initial_page
        session[:notice] = _("Logged in successfully")
      end
    else
      session[:notice] = _('Incorrect username or password') if redirect?
    end
  end

  def logout_popup
    render :action => 'logout_popup', :layout => false
  end

  def login_popup
    @user = User.new
    render :action => 'login', :layout => false
  end

  def signup_time
    key = set_signup_start_time_for_now
    render :text => { :ok=>true, :key=>key }.to_json
  end

  # action to register an user to the application
  def signup
    if @plugins.dispatch(:allow_user_registration).include?(false)
      redirect_back_or_default(:controller => 'home')
      session[:notice] = _("This environment doesn't allow user registration.")
    end

    @block_bot = !!session[:may_be_a_bot]
    @invitation_code = params[:invitation_code]
    begin
      @user = User.new(params[:user])
      @user.terms_of_use = environment.terms_of_use
      @user.environment = environment
      @terms_of_use = environment.terms_of_use
      @user.person_data = params[:profile_data]
      @person = Person.new(params[:profile_data])
      @person.environment = @user.environment
      if request.post?
        if may_be_a_bot
          set_signup_start_time_for_now
          @block_bot = true
          session[:may_be_a_bot] = true
        else
          if session[:may_be_a_bot]
            return false unless verify_recaptcha :model=>@user, :message=>_('Captcha (the human test)')
          end
          @user.signup!
          owner_role = Role.find_by_name('owner')
          @user.person.affiliate(@user.person, [owner_role]) if owner_role
          invitation = Task.find_by_code(@invitation_code)
          if invitation
            invitation.update_attributes!({:friend => @user.person})
            invitation.finish
          end
          if @user.activated?
            self.current_user = @user
            redirect_to '/'
          else
            @register_pending = true
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      @person.valid?
      @person.errors.delete(:identifier)
      @person.errors.delete(:user_id)
      render :action => 'signup'
    end
    clear_signup_start_time
  end

  # action to perform logout from the application
  def logout
    if logged_in?
      self.current_user.forget_me
    end
    reset_session
    session[:notice] = _("You have been logged out.")
    redirect_to :controller => 'home', :action => 'index'
  end

  def change_password
    if request.post?
      @user = current_user
      begin 
        @user.change_password!(params[:current_password],
                               params[:new_password],
                               params[:new_password_confirmation])
        session[:notice] = _('Your password has been changed successfully!')
        redirect_to :action => 'index'
      rescue User::IncorrectPassword => e
        session[:notice] = _('The supplied current password is incorrect.')
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
    if @plugins.dispatch(:allow_password_recovery).include?(false)
      redirect_back_or_default(:controller => 'home')
      session[:notice] = _("This environment doesn't allow password recovery.")
    end
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
    valid = Person.is_available?(@identifier, environment)
    if valid
      @status = _('This login name is available')
      @status_class = 'validated'
    else
      @status = _('This login name is unavailable')
      @status_class = 'invalid'
    end
    render :partial => 'identifier_status'
  end

  def check_email
    if User.find_by_email_and_environment_id(params[:address], environment.id).nil?
      @status = _('This e-mail address is available')
      @status_class = 'validated'
    else
      @status = _('This e-mail address is taken')
      @status_class = 'invalid'
    end
    render :partial => 'email_status'
  end

  def user_data
    user_data =
      if logged_in?
        current_user.data_hash
      else
        { }
      end
    if session[:notice]
      user_data['notice'] = session[:notice]
      session[:notice] = nil # consume the notice
    end

    @plugins.each { |plugin| user_data.merge!(plugin.user_data_extras) }

    render :text => user_data.to_json, :layout => false, :content_type => "application/javascript"
  end

  protected

  def redirect?
    !@cannot_redirect
  end

  def no_redirect
    @cannot_redirect = true
  end

  def set_signup_start_time_for_now
    key = 'signup_start_time_' + rand.to_s.split('.')[1]
    Rails.cache.write key, Time.now
    key
  end

  def get_signup_start_time
    Rails.cache.read params[:signup_time_key]
  end

  def clear_signup_start_time
    Rails.cache.delete params[:signup_time_key] if params[:signup_time_key]
  end

  def may_be_a_bot
    # No minimum signup delay, no bot test.
    return false if environment.min_signup_delay == 0

    # answering captcha, may be human!
    return false if params[:recaptcha_response_field]

    # never set signup_time, hi wget!
    signup_start_time = get_signup_start_time
    return true if signup_start_time.nil?

    # so fast, so bot.
    signup_start_time > ( Time.now - environment.min_signup_delay.seconds )
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

  def go_to_initial_page
    if environment.enabled?('allow_change_of_redirection_after_login')
      case user.preferred_login_redirection
        when 'keep_on_same_page'
          redirect_back_or_default(user.admin_url)
        when 'site_homepage'
          redirect_to :controller => :home
        when 'user_profile_page'
          redirect_to user.public_profile_url
        when 'user_homepage'
          redirect_to user.url
        when 'user_control_panel'
          redirect_to user.admin_url
      else
        redirect_back_or_default(user.admin_url)
      end
    else
      if environment == current_user.environment
        redirect_back_or_default(user.admin_url)
      else
        redirect_back_or_default(:controller => 'home')
      end
    end
  end

  def redirect_if_logged_in
    if logged_in?
      go_to_initial_page
    end
  end

  def plugins_alternative_authentication
    user = nil
    @plugins.each do |plugin|
      user = plugin.alternative_authentication
      break unless user.nil?
    end
    user
  end

end
