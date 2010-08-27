class InviteController < PublicController

  needs_profile
  before_filter :login_required
  before_filter :check_permissions_to_invite

  def select_address_book
    @import_from = params[:import_from] || "manual"
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
        Delayed::Job.enqueue InvitationJob.new(current_user.person.id, contacts_to_invite, params[:mail_template], profile.id, @contact_list.id)
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
    redirect_to :action => 'select_address_book'
  end

  protected

  def check_permissions_to_invite
    if profile.person? and !current_user.person.has_permission?(:manage_friends, profile) or
      profile.community? and !current_user.person.has_permission?(:invite_members, profile)
      render_access_denied
    end
  end

end
