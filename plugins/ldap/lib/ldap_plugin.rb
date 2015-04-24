require File.dirname(__FILE__) + '/ldap_authentication.rb'

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
    def ldap_plugin_set_profile_data(attrs, login, params)
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
    false
  end

  def alternative_authentication
    login = context.params[:user][:login]
    password = context.params[:user][:password]
    ldap = LdapAuthentication.new(context.environment.ldap_plugin_attributes)

    user = User.find_or_initialize_by_login(login)

    if user.new_record?
      # user is not yet registered, try to authenticate
      begin
        attrs = ldap.authenticate(login, password)
      rescue Net::LDAP::LdapError => e
        puts "LDAP is not configured correctly"
      end

      if attrs
        user.login = login
        user.email = attrs[:mail]
        user.name =  attrs[:fullname]
        user.password = password
        user.password_confirmation = password
        person_data = plugins.dispatch(:ldap_plugin_set_profile_data, attrs, login, context.params)
        user.person_data = person_data.blank? ? context.params[:profile_data] : person_data
        user.activated_at = Time.now.utc
        user.activation_code = nil

        ldap = LdapAuthentication.new(context.environment.ldap_plugin_attributes)
        begin
          user = nil unless user.save!
          plugins.dispatch(:ldap_plugin_update_user, user, attrs)
        rescue
          #User not saved
        end
      else
        user = nil
      end

    else
      return nil if !user.activated?

      begin
        # user is defined as nil if ldap authentication failed
        user = nil if ldap.authenticate(login, password).nil?
      rescue Net::LDAP::LdapError => e
        user = nil
        puts "LDAP is not configured correctly"
      end
    end

    user
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
