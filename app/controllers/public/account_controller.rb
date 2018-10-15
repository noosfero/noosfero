class AccountController < ApplicationController

  no_design_blocks

  before_filter :login_required, :require_login_for_environment, :only => [:activation_question, :accept_terms, :activate_enterprise, :change_password]
  before_filter :redirect_if_logged_in, :only => [:login, :signup, :activate]
  before_filter :protect_from_spam, :only => :signup
  before_filter :check_activation_token, :only => [:activate, :resend_activation_codes]

  protect_from_forgery except: [:login]

  include Captcha

  helper CustomFieldsHelper
  # say something nice, you goof!  something sweet.
  def index
    unless logged_in?
      render :action => 'index_anonymous'
    end
  end

  def activate
    @user = User.find_by(activation_code: params[:activation_token])

    if @user.nil?
      session[:notice] = _("We couldn't find an account to be activated. "\
                           "Maybe it is to be approved by an admin.")
      redirect_to action: :login
    end

    if request.post?
      if @user.activate(params[:short_activation_code])
        check_redirection
        session[:join] = params[:join] unless params[:join].blank?

        if @user.activated?
          session[:notice] = _('Your account was successfully activated!')
          self.current_user = @user
          go_to_initial_page
        else
          session[:notice] = _('Your account was activated, now wait until '\
                               'an administrator approves your account.')
          redirect_to controller: :home, action: :welcome,
                      template_id: @user.person.template.try(:id)
        end
      else
        session[:notice] = _('Looks like your activation code is not correct. '\
                             'Would you try again?')
        redirect_to action: :activate, activation_token: @user.activation_code
      end
    end
  rescue ActiveRecord::RecordInvalid
    session[:notice] = _('Something went wrong. You can try again, and if it '\
                         'persists, contact an administrator.')
    redirect_to action: :activate, activation_token: @user.activation_code
  end

  def resend_activation_codes
    @user = User.find_by(activation_code: params[:activation_token])
    unless @user.present?
      session[:notice] = _('Invalid activation token. Maybe this account '\
                           'was already activated?')
      redirect_to action: :login
      return
    end

    @user.resend_activation_code
    session[:notice] = _('A new activation code is on its way. Make sure to '\
                         'use the last code you received.')
    redirect_to action: :activate, activation_token: @user.activation_code
  end

  # action to perform login to the application
  def login
    store_location(request.referer) unless params[:return_to] or session[:return_to]

    return unless request.post?

    self.current_user = plugins_alternative_authentication

    begin
      self.current_user ||= User.authenticate(params[:user][:login], params[:user][:password], environment) if params[:user]
    rescue User::UserNotActivated => e
      if e.user.activation_code.present?
        redirect_to action: :activate, activation_token: e.user.activation_code
      else
        session[:notice] = _('An admin will approve your account soon.')
        redirect_to action: :login
      end
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

  # action to register an user to the application
  def signup
    if @plugins.dispatch(:allow_user_registration).include?(false)
      redirect_back_or_default(:controller => 'home')
      session[:notice] = _("This environment doesn't allow user registration.")
      return
    end

    store_location(request.referer) unless params[:return_to] or session[:return_to]

    @invitation_code = params[:invitation_code]
    begin
      @user = User.build(params[:user], params[:profile_data], environment)
      @user.session = session
      @terms_of_use = environment.terms_of_use
      @user.return_to = session[:return_to]
      @person = Person.new(params[:profile_data])
      @person.environment = @user.environment
      @kinds = environment.kinds.where(:type => 'Person')

      if request.post?
        if verify_captcha(:signup, @user, nil, environment)
          @user.community_to_join = session[:join]
          @user.signup!
          invitation = Task.from_code(@invitation_code).first
          if invitation
            invitation.update! friend: @user.person
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
            redirect_to action: :activate,
                        activation_token: @user.activation_code,
                        return_to: { controller: :home, action: :welcome,
                                     template_id: @user.person.template.try(:id) }
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      @person.valid?
      @person.errors.delete(:identifier)
      @person.errors.delete(:user_id)
      render :action => 'signup'
    end
  end

  # action to perform logout from the application
  def logout
    if logged_in?
      self.current_user.forget_me
      current_user.update({:chat_status_at => DateTime.now}.merge({:last_chat_status => current_user.chat_status, :chat_status => 'offline'}))
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
        return false unless verify_captcha(:forgot_password, @change_password, nil, environment)

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
          @change_password.errors[:base] << _('Could not find any user with %s equal to "%s".').html_safe % [fields_label, params[:value]]
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
    @change_password = ChangePassword.from_code(params[:code]).first

    unless @change_password
      render :action => 'invalid_change_password_code', :status => 403
      return
    end

    if request.post?
      begin
        @change_password.update!(params[:change_password])
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
    if User.find_by(email: params[:address], environment_id: environment.id).nil?
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
    @enterprise_activation ||= EnterpriseActivation.from_code(params[:enterprise_code]).first
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
      redirect_to url_for(params[:return_to])
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
      @user.update(:return_to => nil)
    end
  end

  def check_join_in_community(user)
    profile_to_join = session[:join]
    unless profile_to_join.blank?
     environment.profiles.find_by(identifier: profile_to_join).add_member(user.person)
     session.delete(:join)
    end
  end

  def check_activation_token
    redirect_to action: :login unless params[:activation_token].present?
  end
end
