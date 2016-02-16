require_relative 'ldap_authentication.rb'

class LdapPlugin < Noosfero::Plugin
  include Noosfero::Plugin::HotSpot

  def self.plugin_name
    "LdapPlugin"
  end

  def self.plugin_description
    _("A plugin that add ldap support.")
  end

  module Hotspots
    # -> Custom ldap plugin hotspot to set profile data before user creation
    # receive the followings params:
    # - attrs with ldap received data
    # - login received by ldap
    # - params from current context
    # returns = updated person_data hash
    def ldap_plugin_set_profile_data(attrs, params)
      [attrs, params]
    end

    # -> Custom ldap plugin hotspot to update user object
    # receive the followings params:
    # - user: user object
    # - attrs with ldap received data
    # returns = none
    def ldap_plugin_update_user(user, attrs)
    end
  end

  def allow_user_registration
    false
  end

  def allow_password_recovery
    context.environment.ldap_plugin['allow_password_recovery']
  end

  def alternative_authentication
    login = context.params[:user][:login]
    password = context.params[:user][:password]
    ldap = LdapAuthentication.new(context.environment.ldap_plugin_attributes)

    # try to authenticate
    begin
      attrs = ldap.authenticate(login, password)
    rescue Net::LDAP::LdapError => e
      puts "LDAP is not configured correctly"
    end
    return nil if attrs.nil?

    user_login = get_login(attrs, ldap.attr_login, login)
    user = User.find_or_initialize_by_login(user_login)
    return nil if !user.new_record? && !user.activated?

    user.login = user_login
    user.email = get_email(attrs, login)
    user.name =  attrs[:fullname]
    user.password = password
    user.password_confirmation = password
    user.person_data = plugins.pipeline(:ldap_plugin_set_profile_data, attrs, context.params).last[:profile_data]
    user.activated_at = Time.now.utc
    user.activation_code = nil

    ldap = LdapAuthentication.new(context.environment.ldap_plugin_attributes)
    begin
      if user.save
        user.activate
        plugins.dispatch(:ldap_plugin_update_user, user, attrs)
      else
        user = nil
      end
    rescue
      #User not saved
    end

    user
  end

  def get_login(attrs, attr_login, login)
    user_login = Array.wrap(attrs[attr_login.split.first.to_sym])
    user_login.empty? ? login : user_login.first
  end

  def get_email(attrs, login)
    return attrs[:mail] unless attrs[:mail].blank?

    if attrs[:fullname]
      return attrs[:fullname].to_slug + "@ldap.user"
    else
      return login.to_slug + "@ldap.user"
    end
  end

  def login_extra_contents
    proc do
      @person = Person.new(:environment => @environment)
      @profile_data = @person
      labelled_fields_for :profile_data, @person do |f|
        render :partial => 'profile_editor/person_form', :locals => {:f => f}
      end
    end
  end

end
