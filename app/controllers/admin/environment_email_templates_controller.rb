class EnvironmentEmailTemplatesController < EmailTemplatesController

  protect 'manage_email_templates', :environment

  protected

  def owner
    environment
  end

  before_filter :only => :index do
    @back_to = url_for(:controller => :admin_panel)
  end

end
