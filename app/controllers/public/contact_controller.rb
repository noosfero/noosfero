class ContactController < PublicController

  needs_profile
  before_filter :allow_access_to_page

  include Captcha

  def new
    @contact = build_contact
    if request.post? && params[:confirm] == 'true'
      @contact.city = (!params[:city].blank? && City.exists?(:id => params[:city])) ? City.find(params[:city]).name : nil
      @contact.state = (!params[:state].blank? && State.exists?(:id => params[:state])) ? State.find(params[:state]).name : nil
      if verify_captcha(:new_contact, @contact, user, environment, profile) && @contact.deliver
        session[:notice] = _('Contact successfully sent')
        redirect_to :action => 'new'
      else
        session[:notice] = _('Contact not sent')
      end
    end
  end

  protected

  def build_contact
    params[:contact] ||= {}
    if logged_in?
      user.build_contact profile, params[:contact]
    else
      Contact.new params[:contact].merge(dest: profile)
    end
  end

end
