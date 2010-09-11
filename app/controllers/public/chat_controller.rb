class ChatController < PublicController

  before_filter :login_required
  before_filter :check_environment_feature

  def start_session
    login = current_user.jid
    password = current_user.crypted_password
    begin
      jid, sid, rid = RubyBOSH.initialize_session(login, password, "http://#{environment.default_hostname}/http-bind")
      session_data = { :jid => jid, :sid => sid, :rid => rid }
      render :text => session_data.to_json, :layout => false, :content_type => 'application/javascript'
    rescue
      render :action => 'start_session_error', :layout => false, :status => 500
    end
  end

  def avatar
    person = environment.people.find_by_identifier(params[:id])
    filename, mimetype = profile_icon(person, :minor, true)
    data = File.read(File.join(RAILS_ROOT, 'public', filename))
    render :text => data, :layout => false, :content_type => mimetype
    expires_in 24.hours
  end

  def index
    presence = current_user.last_presence_status
    if presence.blank?
      render :text => '', :layout => 'chat'
    elsif presence == 'chat'
      render :action => 'auto_connect_online'
    else
      render :action => 'auto_connect_busy'
    end
  end

  def update_presence_status
    if request.xhr?
      unless params[:closing_window]
        current_user.update_attribute(:last_presence_status, params[:presence_status])
      end
      current_user.update_attribute(:presence_status, params[:presence_status])
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
