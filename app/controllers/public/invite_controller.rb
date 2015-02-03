class InviteController < PublicController

  needs_profile
  before_filter :login_required
  before_filter :check_permissions_to_invite

  def invite_friends
    @import_from = params[:import_from] || "manual"
    @mail_template = params[:mail_template] || environment.invitation_mail_template(profile)

    labels = Profile::SEARCHABLE_FIELDS.except(:nickname).merge(User::SEARCHABLE_FIELDS).map { |name,info| info[:label].downcase }
    last = labels.pop
    label = labels.join(', ')
    @search_fields = "#{label} #{_('or')} #{last}"

    if request.post?
      contact_list = ContactList.create
      Delayed::Job.enqueue GetEmailContactsJob.new(@import_from, params[:login], params[:password], contact_list.id) if @import_from != 'manual'
      redirect_to :action => 'select_friends', :contact_list => contact_list.id, :import_from => @import_from
    end
  end

  def select_friends
    @contact_list = ContactList.find(params[:contact_list])
    @mail_template = params[:mail_template] || environment.invitation_mail_template(profile)
    @import_from = params[:import_from] || "manual"
    if request.post?
      manual_import_addresses = params[:manual_import_addresses]
      webmail_import_addresses = params[:webmail_import_addresses]
      contacts_to_invite = Invitation.join_contacts(manual_import_addresses, webmail_import_addresses)
      if !contacts_to_invite.empty?
        Delayed::Job.enqueue InvitationJob.new(user.id, contacts_to_invite, params[:mail_template], profile.id, @contact_list.id, locale)
        session[:notice] = _('Your invitations are being sent.')
        if profile.person?
          redirect_to :controller => 'profile', :action => 'friends'
        else
          redirect_to :controller => 'profile', :action => 'members'
        end
        return
      else
        session[:notice] = _('Please enter a valid email address.')
      end
      @manual_import_addresses = manual_import_addresses || ""
      @webmail_import_addresses = webmail_import_addresses || []
    end
  end

  def invitation_data
    contact_list = ContactList.find(params[:contact_list])
    render :text => contact_list.data.to_json, :layout => false, :content_type => "application/javascript"
  end

  def add_contact_list
    contact_list = ContactList.find(params[:contact_list])
    contacts = contact_list.list
    render :partial => 'invite/contact_list', :locals => {:contacts => contacts}
  end

  def cancel_fetching_emails
    contact_list = ContactList.find(params[:contact_list])
    contact_list.destroy
    redirect_to :action => 'invite_friends'
  end

  def invite_registered_friend
    contacts_to_invite = params['q'].split(',')
    if !contacts_to_invite.empty? && request.post?
      Delayed::Job.enqueue InvitationJob.new(user.id, contacts_to_invite, '', profile.id, nil, locale)
      session[:notice] = _('Your invitations are being sent.')
      if profile.person?
        redirect_to :controller => 'profile', :action => 'friends'
      else
        redirect_to :controller => 'profile', :action => 'members'
      end
    else
      redirect_to :action => 'invite_friends'
      session[:notice] = _('Please enter a valid profile.')
    end
  end

  def search
    scope = profile.invite_friends_only ? user.friends : environment.people
    scope = scope.not_members_of(profile) if profile.organization?
    scope = scope.not_friends_of(profile) if profile.person?
    results = find_by_contents(:people, environment, scope, params['q'], {:page => 1}, {:joins => :user})[:results]
    render :text => prepare_to_token_input(results).to_json
  end

  protected

  def check_permissions_to_invite
    render_access_denied if !profile.allow_invitation_from?(user)
  end
end
