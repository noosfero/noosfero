class MailconfController < MyProfileController

  requires_profile_class Person

  protect 'edit_profile', :profile

  before_action :check_mail_enabled
  def check_mail_enabled
    unless MailConf.enabled?
      render plain: "Mail is not enabled in noosfero.", :status => 500
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
      session[:notice] = _('Please fill your personal information below in order to get your mailbox approved by one of the administrators')
      redirect_to informations_profile_editor_index_path
    rescue Exception => ex
      session[:notice] = _('e-Mail was not enabled successfully.')
      render :action => 'index'
    end
  end
  post_only :disable
  def disable
    if profile.user.disable_email!
      session[:notice] = _('e-Mail disabled successfully.')
      redirect_to profile_editor_index_path
    else
      session[:notice] = _('e-Mail was not disabled successfully.')
      redirect_to :action => 'index'
    end
  end
  
end
