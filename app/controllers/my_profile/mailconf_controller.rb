class MailconfController < MyProfileController

  requires_profile_class Person

  protect 'edit_profile', :profile

  before_filter :check_mail_enabled
  def check_mail_enabled
    unless MailConf.enabled?
      render :text => "Mail is not enabled in noosfero.", :status => 500
    end
  end

  def index
    @user = profile.user
  end

  post_only :save
  def save
    profile.user.update_attributes(params[:user])
    flash[:notice] = _('e-Mail settings saved successfully.')
    redirect_to :action => 'index'
  end
  
end
