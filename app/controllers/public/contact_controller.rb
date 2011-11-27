class ContactController < PublicController

  before_filter :login_required

  needs_profile

  def new
    @contact
    if request.post? && params[:confirm] == 'true'
      @contact = user.build_contact(profile, params[:contact])
      @contact.city = (!params[:city].blank? && City.exists?(params[:city])) ? City.find(params[:city]).name : nil
      @contact.state = (!params[:state].blank? && State.exists?(params[:state])) ? State.find(params[:state]).name : nil
      if @contact.deliver
        session[:notice] = _('Contact successfully sent')
        redirect_to :action => 'new'
      else
        session[:notice] = _('Contact not sent')
      end
    else
      @contact = user.build_contact(profile)
    end
  end

end
