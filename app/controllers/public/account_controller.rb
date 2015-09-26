class AccountController < ApplicationController

  no_design_blocks

  before_filter :login_required, :require_login_for_environment, :only => [:activation_question, :accept_terms, :activate_enterprise, :change_password]
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
    if @user
      unless @user.environment.enabled?('admin_must_approve_new_users')
        if @user.activate
          @message = _("Your account has been activated, now you can log in!")
          check_redirection
          session[:join] = params[:join] unless params[:join].blank?
          render :action => 'login', :userlogin => @user.login
        end
      else
        if @user.create_moderate_task
          session[:notice] = _('Thanks for registering. The administrators were notified.')
          @register_pending = true
          @user.activation_code = nil
          @user.save!
          redirect_to :controller => :home
        end
      end
    else
      session[:notice] = _("It looks like you're trying to activate an account. Perhaps have already activated this account?")
      redirect_to :controller => :home
    end
  end

  # action to perform login to the application
  def login
    store_location(request.referer) unless params[:return_to] or session[:return_to]

    return unless request.post?

    self.current_user = plugins_alternative_authentication

    begin
      self.current_user ||= User.authenticate(params[:user][:login], params[:user][:password], environment) if params[:user]
    rescue User::UserNotActivated => e
      session[:notice] = e.message
      return
    end
    if logged_in?
      check_join_in_community(self.current_user)

      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = {value: self.current_user.remember_token, expires: self.current_user.remember_token_expires_at}
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
      return
    end

    store_location(request.referer) unless params[:return_to] or session[:return_to]

    # Tranforming to boolean
    @block_bot = !!session[:may_be_a_bot]
    @invitation_code = params[:invitation_code]
    begin
      @user = User.build(params[:user], params[:profile_data], environment)
      @user.session = session
      @terms_of_use = environment.terms_of_use
      @user.return_to = session[:return_to]
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
          @user.community_to_join = session[:join]
          @user.signup!
          owner_role = Role.find_by_name('owner')
          @user.person.affiliate(@user.person, [owner_role]) if owner_role
          invitation = Task.find_by_code(@invitation_code)
          if invitation
            invitation.update_attributes!({:friend => @user.person})
            invitation.finish
          end

          unless params[:file].nil?
            image = Image::new :uploaded_data=> params[:file][:image]

            @user.person.image = image
            @user.person.save
          end

          if @user.activated?
            self.current_user = @user
            check_join_in_community(@user)
            go_to_signup_initial_page
          else
            redirect_to :controller => :home, :action => :welcome, :template_id => (@user.person.template && @user.person.template.id)
            session[:notice] = _('Thanks for registering!')
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
      rescue Exception
      end
    end
  end

  include ForgotPasswordHelper
  helper :forgot_password

  def forgot_password
    if @plugins.dispatch(:allow_password_recovery).include?(false)
      redirect_back_or_default(:controller => 'home')
      session[:notice] = _("This environment doesn't allow password recovery.")
    end

    @change_password = ChangePassword.new

    if request.post?
      begin
        requestors = fetch_requestors(params[:value])
        raise ActiveRecord::RecordNotFound if requestors.blank? || params[:value].blank?

        requestors.each do |requestor|
          ChangePassword.create!(:requestor => requestor)
        end
        render :action => 'password_recovery_sent'
      rescue ActiveRecord::RecordNotFound
        if params[:value].blank?
          @change_password.errors[:base] << _('Can not recover user password with blank value.')
        else
          @change_password.errors[:base] << _('Could not find any user with %s equal to "%s".') % [fields_label, params[:value]]
        end
      rescue ActiveRecord::RecordInvalid
        @change_password.errors[:base] << _('Could not perform password recovery for the user.')
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

  def check_valid_name
    @identifier = params[:identifier]
    valid = Person.is_available?(@identifier, environment)
    if valid
      @status = _('This login name is available')
      @status_class = 'validated'
    elsif !@identifier.empty?
      @suggested_usernames = suggestion_based_on_username(@identifier)
      @status = _('This login name is unavailable')
      @status_class = 'invalid'
    else
      @status_class = 'invalid'
      @status = _('This field can\'t be blank')
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
        current_user.data_hash(gravatar_default)
      else
        { }
      end
    if session[:notice]
      user_data['notice'] = session[:notice]
      session[:notice] = nil # consume the notice
    end

    @plugins.each do |plugin|
      user_data_extras = plugin.user_data_extras
      user_data_extras = instance_exec(&user_data_extras) if user_data_extras.kind_of?(Proc)
      user_data.merge!(user_data_extras)
    end

    render :text => user_data.to_json, :layout => false, :content_type => "application/javascript"
  end

  def search_cities
    if request.xhr? and params[:state_name] and params[:city_name]
      render :json => MapsHelper.search_city(params[:city_name], params[:state_name])
    else
      render :json => [].to_json
    end
  end

  def search_state
    if request.xhr? and params[:state_name]
      render :json => MapsHelper.search_state(params[:state_name])
    else
      render :json => [].to_json
    end
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
    if params[:return_to]
      redirect_to params[:return_to]
    elsif environment.enabled?('allow_change_of_redirection_after_login')
      check_redirection_options(user, user.preferred_login_redirection, user.admin_url)
    else
      if environment == current_user.environment
        check_redirection_options(user, environment.redirection_after_login, user.admin_url)
      else
        redirect_back_or_default(:controller => 'home')
      end
    end
  end

  def go_to_signup_initial_page
    check_redirection_options user, user.environment.redirection_after_signup, user.url, signup: true
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

  protected

  def check_redirection_options user, condition, default, options={}
    if options[:signup] and target = session.delete(:after_signup_redirect_to)
      redirect_to target
    else
      case condition
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
      when 'welcome_page'
        redirect_to :controller => :home, :action => :welcome, :template_id => (user.template && user.template.id)
      when 'custom_url'
        if (url = user.custom_url_redirection).present? then redirect_to url else redirect_back_or_default default end
      else
        redirect_back_or_default(default)
      end
    end
  end

  def check_redirection
    unless params[:redirection].blank?
      session[:return_to] = @user.return_to
      @user.update_attributes(:return_to => nil)
    end
  end

  def check_join_in_community(user)
    profile_to_join = session[:join]
    unless profile_to_join.blank?
     environment.profiles.find_by_identifier(profile_to_join).add_member(user.person)
     session.delete(:join)
    end
  end
end
