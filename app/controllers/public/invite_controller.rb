class InviteController < PublicController

  needs_profile
  before_filter :login_required
  before_filter :check_permissions_to_invite, :only => 'friends'

  def friends
    step = params[:step]
    if request.post?
      if step == '1'
        begin
          @contacts = Invitation.get_contacts(params[:import_from], params[:login], params[:password])
        rescue
          @login = params[:login]
          flash.now[:notice] = _('There was an error while looking for your contact list. Did you enter correct login and password?')
        end
      elsif step == '2'
        manual_import_addresses = params[:manual_import_addresses]
        webmail_import_addresses = params[:webmail_import_addresses]
        contacts_to_invite = Invitation.join_contacts(manual_import_addresses, webmail_import_addresses)
        if !params[:mail_template].match(/<url>/)
          flash.now[:notice] = _('&lt;url&gt; is needed in invitation mail.')
        elsif !contacts_to_invite.empty?
          Delayed::Job.enqueue InvitationJob.new(user.id, contacts_to_invite, params[:mail_template], profile.id)
          session[:notice] = _('Your invitations are being sent.')
          if profile.person?
            redirect_to :controller => 'friends'
          else
            redirect_to :controller => 'profile_members'
          end
        else
          flash.now[:notice] = _('Please enter a valid email address.')
        end
        @contacts = params[:webmail_friends] ? params[:webmail_friends].map {|e| YAML.load(e)} : []
        @manual_import_addresses = manual_import_addresses || ""
        @webmail_import_addresses = webmail_import_addresses || []
      end
    end
    @import_from = params[:import_from] || "manual"
    @mail_template = params[:mail_template] || environment.invitation_mail_template(profile)
  end

  protected

  def check_permissions_to_invite
    if profile.person? and !current_user.person.has_permission?(:manage_friends, profile) or
      profile.community? and !current_user.person.has_permission?(:invite_members, profile)
      render_access_denied
    end
  end

end
