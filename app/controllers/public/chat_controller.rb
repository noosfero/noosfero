class ChatController < PublicController

  before_filter :login_required
  before_filter :check_environment_feature

  def start_session
    login = user.jid
    password = current_user.crypted_password
    begin
      jid, sid, rid = RubyBOSH.initialize_session(login, password, "http://#{environment.default_hostname}/http-bind",
                                                  :wait => 30, :hold => 1, :window => 5)
      session_data = { :jid => jid, :sid => sid, :rid => rid }
      render :text => session_data.to_json, :layout => false, :content_type => 'application/javascript'
    rescue
      render :action => 'start_session_error', :layout => false, :status => 500
    end
  end

  def avatar
    profile = environment.profiles.find_by_identifier(params[:id])
    filename, mimetype = profile_icon(profile, :minor, true)
    data = File.read(File.join(RAILS_ROOT, 'public', filename))
    render :text => data, :layout => false, :content_type => mimetype
    expires_in 24.hours
  end

  def index
    presence = current_user.last_chat_status
    if presence.blank? or presence == 'chat'
      render :action => 'auto_connect_online'
    else
      render :action => 'auto_connect_busy'
    end
  end

  def update_presence_status
    if request.xhr?
      current_user.update_attributes({:chat_status_at => DateTime.now}.merge(params[:status] || {}))
    end
    render :nothing => true
  end

  protected

  def check_environment_feature
    unless environment.enabled?('xmpp_chat')
      render_not_found
      return
    end
  end

end
