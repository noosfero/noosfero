require "contacts"

class FriendsController < MyProfileController
  
  protect 'manage_friends', :profile
  
  def index
    if is_cache_expired?(profile.manage_friends_cache_key(params))
      @friends = profile.friends.paginate(:per_page => per_page, :page => params[:npage])
    end
  end

  def add
    @friend = Person.find(params[:id])
    if request.post? && params[:confirmation]
      # FIXME this shouldn't be in Person model?
      AddFriend.create!(:person => profile, :friend => @friend, :group_for_person => params[:group])

      flash[:notice] = _('%s still needs to accept being your friend.') % @friend.name
      # FIXME shouldn't redirect to the friend's page?
      redirect_to :action => 'index' 
    end
  end

  def remove
    @friend = profile.friends.find(params[:id])
    if request.post? && params[:confirmation]
      profile.remove_friend(@friend)
      redirect_to :action => 'index'
    end
  end

  def invite
    @wizard = params[:wizard].blank? ? false : params[:wizard]
    @step = 3
    if request.post? && params[:import]
      begin
        case params[:import_from]
        when "gmail"
          @friends = Contacts::Gmail.new(params[:login], params[:password]).contacts
        when "yahoo"
          @friends = Contacts::Yahoo.new(params[:login], params[:password]).contacts
        when "hotmail"
          @friends = Contacts::Hotmail.new(params[:login], params[:password]).contacts
        else
          @friends = []
        end
        @friends.map! {|friend| friend + ["#{friend[0]} <#{friend[1]}>"]}
      rescue
        @login = params[:login]
        flash.now[:notice] = __('There was an error while looking for your contact list. Did you enter correct login and password?')
      end

    elsif request.post? && params[:confirmation]
      friends_to_invite = []
      friends_to_invite += (params[:manual_import_addresses].is_a?(Array) ? params[:manual_import_addresses] : params[:manual_import_addresses].split("\r\n")) if params[:manual_import_addresses]
      friends_to_invite += (params[:webmail_import_addresses].is_a?(Array) ? params[:webmail_import_addresses] : params[:webmail_import_addresses].split("\r\n")) if params[:webmail_import_addresses]

      if !params[:message].match(/<url>/)
        flash.now[:notice] = __('&lt;url&gt; is needed in invitation message.')
      elsif !friends_to_invite.empty?
        friends_to_invite.each do |friend_to_invite|
          next if friend_to_invite == __("Firstname Lastname <friend@email.com>")

          friend_to_invite.strip!
          if match = friend_to_invite.match(/(.*)<(.*)>/) and match[2].match(Noosfero::Constants::EMAIL_FORMAT)
            friend_name = match[1].strip
            friend_email = match[2]
          elsif match = friend_to_invite.strip.match(Noosfero::Constants::EMAIL_FORMAT)
            friend_name = ""
            friend_email = match[0]
          else
            next
          end

          friend = User.find_by_email(friend_email)
          if !friend.nil? && friend.person.person?
            InviteFriend.create(:person => profile, :friend => friend.person)
          else
            InviteFriend.create(:person => profile, :friend_name => friend_name, :friend_email => friend_email, :message =>  params[:message])
          end
        end

        flash[:notice] = __('Your invitations have been sent.')
        if @wizard
          redirect_to :action => 'invite', :wizard => true
	  return
	else
          redirect_to :action => 'index'
        end
      else
        flash.now[:notice] = __('Please enter a valid email address.')
      end

      @friends = params[:webmail_friends] ? params[:webmail_friends].map {|e| YAML.load(e)} : []
      @manual_import_addresses = params[:manual_import_addresses] || ""
      @webmail_import_addresses = params[:webmail_import_addresses] || []
    end

    @import_from = params[:import_from] || "manual"
    @message = params[:message] || environment.message_for_friend_invitation
    if @wizard
      if !params[:import]
        @friends = []
      end
      render :layout => 'wizard'
    end
  end

  protected

  class << self
    def per_page
      10
    end
  end
  def per_page
    self.class.per_page
  end
end
