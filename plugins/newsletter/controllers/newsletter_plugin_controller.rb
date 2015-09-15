class NewsletterPluginController < PublicController

  before_filter :login_required, :only => :confirm_unsubscription

  def mailing
    if NewsletterPlugin::NewsletterMailing.exists?(params[:id])
      mailing = NewsletterPlugin::NewsletterMailing.find(params[:id])
      @message = mailing.body
      render :file => 'mailing/sender/notification', :layout => false
    else
      render :action => 'mailing_not_found'
    end
  end

  def confirm_unsubscription
    if request.post?
      session[:notice] = _('You were unsubscribed from newsletter.')
      @newsletter = NewsletterPlugin::Newsletter.where(environment_id: environment.id).first
      @newsletter.unsubscribe(current_user.email)
      redirect_to :controller => :home
    end
  end

end
