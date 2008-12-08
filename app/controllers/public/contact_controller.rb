class ContactController < PublicController

  needs_profile

  def new
    @contact
    if request.post?
      @contact = Contact.new(params[:contact])
      @contact.dest = profile
      @contact.city = City.exists?(params[:city]) ? City.find(params[:city]).name : _('Missing')
      @contact.state = State.exists?(params[:state]) ? State.find(params[:state]).name : _('Missing')
      if @contact.deliver
        flash[:notice] = _('Contact successfully sent')
        redirect_to :action => 'new'
      else
        flash[:notice] = _('Contact not sent')
      end
    else
      if logged_in?
        @contact = Contact.new(:name => user.name, :email => user.email)
      else
        @contact = Contact.new
      end
    end
  end

end
