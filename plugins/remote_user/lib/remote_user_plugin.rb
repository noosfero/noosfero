class RemoteUserPlugin < Noosfero::Plugin

  def self.plugin_name
    "Remote User Plugin"
  end

  def self.plugin_description
    _("A plugin that add remote user support.")
  end

  def application_controller_filters
    block = proc do

      begin
        remote_user = request.headers["HTTP_REMOTE_USER"]
        user_data = request.env['HTTP_REMOTE_USER_DATA']

        if remote_user.blank?
          self.current_user = nil
        else
          if user_data.blank?
            remote_user_email = remote_user + '@remote.user'
            remote_user_name = remote_user
          else
            user_data = JSON.parse(user_data)
            remote_user_email = user_data['email']
            remote_user_name = user_data['name']
          end

          if !logged_in?
            self.current_user = User.where(environment_id: environment, login: remote_user).first
            unless self.current_user
              self.current_user = User.create!(:environment => environment, :login => remote_user, :email => remote_user_email, :name => remote_user_name, :password => ('pw4'+remote_user), :password_confirmation => ('pw4'+remote_user))
              self.current_user.activate
            end
            self.current_user.save!
          else
            if remote_user != self.current_user.login
              self.current_user.forget_me
              reset_session

	      self.current_user = User.where(environment_id: environment, login: remote_user).first
              unless self.current_user
                self.current_user = User.create!(:environment => environment, :login => remote_user, :email => remote_user_email, :name => remote_user_name, :password => ('pw4'+remote_user), :password_confirmation => ('pw4'+remote_user))
                self.current_user.activate
              end
              self.current_user.save!
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
