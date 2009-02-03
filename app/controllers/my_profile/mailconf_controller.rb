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

  post_only :enable
  def enable
    @task = EmailActivation.new(:target => environment, :requestor => profile)
    begin
      @task.save!
      flash[:notice] = _('Please fill your personal information below in order to get your mailbox approved by one of the administrators')
      redirect_to :controller => 'profile_editor', :action => 'edit'
    rescue Exception => ex
      flash[:notice] = _('e-Mail was not enabled successfully.')
      render :action => 'index'
    end
  end
  post_only :disable
  def disable
    if profile.user.disable_email!
      flash[:notice] = _('e-Mail disabled successfully.')
      redirect_to :controller => 'profile_editor'
    else
      flash[:notice] = _('e-Mail was not disabled successfully.')
      redirect_to :action => 'index'
    end
  end
  
end
