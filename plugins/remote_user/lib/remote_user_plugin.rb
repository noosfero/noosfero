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

        if remote_user.nil?
          if logged_in?
            self.current_user.forget_me
            reset_session
          end
        else
          if !logged_in?
            self.current_user = User.find_by_login(remote_user)
            unless self.current_user
              self.current_user = User.create!(:login => remote_user, :email => (remote_user + '@remote.user'), :password => ('pw4'+remote_user), :password_confirmation => ('pw4'+remote_user))
            end
            self.current_user.save!
          else
            if remote_user != self.current_user.login
              self.current_user.forget_me
              reset_session

              self.current_user = User.find_by_login(remote_user)
              unless self.current_user
                self.current_user = User.create!(:login => remote_user, :email => (remote_user + '@remote.user'), :password => ('pw4'+remote_user), :password_confirmation => ('pw4'+remote_user))
              end
              self.current_user.save!
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => invalid
        session[:notice] = _('Could not create the remote_user.')
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
