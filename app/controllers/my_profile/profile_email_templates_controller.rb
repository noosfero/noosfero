class ProfileEmailTemplatesController < EmailTemplatesController

  needs_profile
  protect 'manage_email_templates', :profile

  protected

  def owner
    profile
  end

  before_filter :only => :index do
    @back_to = url_for(:controller => :profile_editor)
  end

end
