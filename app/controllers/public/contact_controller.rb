class ContactController < PublicController

  before_filter :login_required

  needs_profile

  inverse_captcha :field => 'e_mail'
  def new
    @contact
    if request.post? && params[self.icaptcha_field].blank?
      @contact = Contact.new(params[:contact])
      @contact.dest = profile
      @contact.sender = user
      @contact.city = (!params[:city].blank? && City.exists?(params[:city])) ? City.find(params[:city]).name : nil
      @contact.state = (!params[:state].blank? && State.exists?(params[:state])) ? State.find(params[:state]).name : nil
      if @contact.deliver
        flash[:notice] = _('Contact successfully sent')
        redirect_to :action => 'new'
      else
        flash[:notice] = _('Contact not sent')
      end
    else
      @contact = Contact.new(:name => user.name, :email => user.email)
    end
  end

end
