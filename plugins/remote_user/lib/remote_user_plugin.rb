class RemoteUserPlugin < Noosfero::Plugin

  def self.plugin_name
    "Remote User Plugin"
  end

  def self.plugin_description
    _("A plugin that add remote user support.")
  end

  def api_custom_login request
    RemoteUserPlugin::current_user request, environment
  end

  def self.current_user request, environment
    remote_user = request.env["HTTP_REMOTE_USER"]
    user_data = request.env['HTTP_REMOTE_USER_DATA']

    remote_user_email = user_data.blank? ? (remote_user + '@remote.user') : JSON.parse(user_data)['email']
    remote_user_name = user_data.blank? ? remote_user : JSON.parse(user_data)['name']

    user = User.where(environment_id: environment, login: remote_user).first
    unless user
      user = User.create!(:environment => environment, :login => remote_user, :email => remote_user_email, :name => remote_user_name, :password => ('pw4'+remote_user), :password_confirmation => ('pw4'+remote_user))
      user.activate
      user.save!
    end
    user
  end

  def application_controller_filters
    block = proc do

      begin
        remote_user = request.headers["HTTP_REMOTE_USER"]

        if remote_user.blank?
          self.current_user = nil
        else
          if !logged_in?
            self.current_user = RemoteUserPlugin::current_user request, environment
          else
            if remote_user != self.current_user.login
              self.current_user.forget_me
              reset_session
              self.current_user = RemoteUserPlugin::current_user request, environment
            end
          end
        end
      rescue ::ActiveRecord::RecordInvalid
        session[:notice] = _('Could not create the remote user.')
        render_404
      rescue
        session[:notice] = _("Could not log in.")
        render_404
      end
    end

    [{
      :type => "before_filter",
      :method_name => "remote_user_authentication",
      :options => { },
      :block => block
    }]
  end
end
