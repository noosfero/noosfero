class ChatController < PublicController

  before_filter :login_required
  before_filter :check_environment_feature
  before_filter :can_send_message, :only => :register_message

  def start_session
    login = user.jid
    password = current_user.crypted_password
    session[:chat] ||= {:rooms => []}
    begin
      jid, sid, rid = RubyBOSH.initialize_session(login, password, "http://#{environment.default_hostname}/http-bind",
                                                  :wait => 30, :hold => 1, :window => 5)
      session_data = { :jid => jid, :sid => sid, :rid => rid }
      render :text => session_data.to_json, :layout => false, :content_type => 'application/javascript'
    rescue
      render :action => 'start_session_error', :layout => false, :status => 500
    end
  end

  def toggle
    session[:chat][:status] = session[:chat][:status] == 'opened' ? 'closed' : 'opened'
    render :nothing => true
  end

  def tab
    session[:chat][:tab_id] = params[:tab_id]
    render :nothing => true
  end

  def join
    session[:chat][:rooms] << params[:room_id]
    session[:chat][:rooms].uniq!
    render :nothing => true
  end

  def leave
    session[:chat][:rooms].delete(params[:room_id])
    render :nothing => true
  end

  def my_session
    render :text => session[:chat].to_json, :layout => false
  end

  def avatar
    profile = environment.profiles.find_by_identifier(params[:id])
    filename, mimetype = profile_icon(profile, :minor, true)
    if filename =~ /^(https?:)?\/\//
      redirect_to filename
    else
      data = File.read(File.join(Rails.root, 'public', filename))
      render :text => data, :layout => false, :content_type => mimetype
      expires_in 24.hours
    end
  end

  def avatars
    profiles = environment.profiles.where(:identifier => params[:profiles])
    avatar_map = profiles.inject({}) do |result, profile|
      result[profile.identifier] = profile_icon(profile, :minor)
      result
    end

    render_json avatar_map
  end

  def update_presence_status
    if request.xhr?
      current_user.update_attributes({:chat_status_at => DateTime.now}.merge(params[:status] || {}))
    end
    render :nothing => true
  end

  def save_message
    if request.post?
      to = environment.profiles.where(:identifier => params[:to]).first
      body = params[:body]

      begin
        ChatMessage.create!(:to => to, :from => user, :body => body)
        return render_json({:status => 0})
      rescue Exception => exception
        return render_json({:status => 3, :message => exception.to_s, :backtrace => exception.backtrace})
      end
    end
  end

  def recent_messages
    other = environment.profiles.find_by_identifier(params[:identifier])
    if other.kind_of?(Organization)
      messages = ChatMessage.where('to_id=:other', :other => other.id)
    else
      messages = ChatMessage.where('(to_id=:other and from_id=:me) or (to_id=:me and from_id=:other)', {:me => user.id, :other => other.id})
    end

    messages = messages.order('created_at DESC').includes(:to, :from).offset(params[:offset]).limit(20)
    messages_json = messages.map do |message|
      {
        :body => message.body,
        :to => {:id => message.to.identifier, :name => message.to.name},
        :from => {:id => message.from.identifier, :name => message.from.name},
        :created_at => message.created_at
      }
    end
    render :json => messages_json.reverse
  end

  def recent_conversations
    profiles = Profile.find_by_sql("select profiles.* from profiles inner join (select distinct r.id as id, MAX(r.created_at) as created_at from (select from_id, to_id, created_at, (case when from_id=#{user.id} then to_id else from_id end) as id from chat_messages where from_id=#{user.id} or to_id=#{user.id}) as r group by id order by created_at desc, id) as t on profiles.id=t.id order by t.created_at desc")
    jids = profiles.map(&:jid).reverse
    render :json => jids.to_json
  end

  #TODO Ideally this is done through roster table on ejabberd.
  def roster_groups
    render :text => user.memberships.map {|m| {:jid => m.jid, :name => m.name}}.to_json
  end

  protected

  def check_environment_feature
    unless environment.enabled?('xmpp_chat')
      render_not_found
      return
    end
  end

  def can_send_message
    return render_json({:status => 1, :message => 'Missing parameters!'}) if params[:from].nil? || params[:to].nil? || params[:message].nil?
    return render_json({:status => 2, :message => 'You can not send message as another user!'}) if params[:from] != user.jid
    # TODO Maybe register the jid in a table someday to avoid this below
    return render_json({:status => 3, :messsage => 'You can not send messages to strangers!'}) if user.friends.where(:identifier => params[:to].split('@').first).blank?
  end

  def render_json(result)
    render :text => result.to_json
  end
end
