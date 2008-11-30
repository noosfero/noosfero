class ContactController < PublicController

  needs_profile

  def new
    @contact = Contact.new(params[:contact])
    if request.post?
      if @contact.save
        flash[:notice] = _('Contact successfully sent')
        redirect_to :controller => 'profile', :profile => profile.identifier
      else
        flash[:notice] = _('Contact not sent')
      end
    end
  end

end
