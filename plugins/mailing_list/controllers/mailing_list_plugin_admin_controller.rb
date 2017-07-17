class MailingListPluginAdminController < PluginAdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    load_client
  end

  def manage_communities
    @kind = :communities
    load_client
    load_groups
  end

  def manage_enterprises
    @kind = :enterprises
    load_client
    load_groups
  end

  def edit
    @settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    if request.post?
      @settings.api_url = params[:settings][:api_url]
      @settings.web_interface_url = params[:settings][:web_interface_url]
      @settings.administrator_email = params[:settings][:administrator_email]
      @settings.administrator_password = params[:settings][:administrator_password] unless params[:settings][:administrator_password].blank?

      begin
        MailingListPlugin::Client.new(@settings)
        if @settings.save!
          session[:notice] = _('The settings were saved successfully')
          redirect_to action: :index
        else
          session[:notice] = _('There were some problems saving the settings')
        end

      rescue Exception => exception
        logger.error("[E] #{exception.class.name}: #{exception.message}")
        session[:notice] = _('Could not connect to the Sympa API')
      end
    end
  end

  def activate
    begin
      load_profile_settings
      @profile_settings.enabled = true
      @profile_settings.save!
      session[:notice] = _('The mailing list is now sending emails!')
    rescue
      session[:notice] = _('The mailing list could not be activated')
    end
    redirect_to action: :index
  end

  def activate_all
    environment.send(params[:kind]).no_templates.find_each do |group|
      begin
        group_settings = Noosfero::Plugin::Settings.new group, MailingListPlugin
        group_settings.enabled = true
        group_settings.save!
      rescue
      end
    end
    session[:notice] = _('All %s mailing lists are activated') % params[:kind]
    redirect_to action: "manage_#{params[:kind]}"
  end

  def deactivate
    begin
      load_profile_settings
      @profile_settings.enabled = false
      @profile_settings.save!
      session[:notice] = _('The mailing list is not sending any emails now')
    rescue
      session[:notice] = _('The mailing list could not be deactivated')
    end
    redirect_to action: :index
  end

  def deactivate_all
    environment.send(params[:kind]).no_templates.find_each do |group|
      begin
        group_settings = Noosfero::Plugin::Settings.new group, MailingListPlugin
        group_settings.enabled = false
        group_settings.save!
      rescue
      end
    end
    session[:notice] = _('All %s mailing lists are deactivated') % params[:kind]
    redirect_to action: "manage_#{params[:kind]}"
  end

  def deploy
    begin
      load_profile_settings
      load_client
      @client.deploy_list_for_group(@profile)
      session[:notice] = _('The mailing list is now deployed!')
    rescue
      session[:notice] = _('The mailing list could not be deployed')
    end
    redirect_to action: :index
  end

  def deploy_all
    load_client
    unless @environment_settings.send("deploying_#{params[:kind]}")
      Delayed::Job.enqueue MailingListPlugin::DeployAllJob.new(environment.id, params[:kind])
      @environment_settings.send("deploying_#{params[:kind]}=", true)
      @environment_settings.save!

      session[:notice] = _('The mailing lists are being deployed. This may take several minutes.')
    end

    redirect_to action: "manage_#{params[:kind]}"
  end

  private

  def per_page
    20
  end

  def load_client
    begin
     @environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
     @client = MailingListPlugin::Client.new(@environment_settings)
     @connection = true
    rescue
      @connection = false
    end
  end

  def load_profile_settings
    @profile = environment.profiles.find params[:id]
    @profile_settings = Noosfero::Plugin::Settings.new profile, MailingListPlugin
  end

  def load_groups
    if @connection
      @collection = environment.send(@kind).no_templates.order('name ASC').paginate(:per_page => per_page, :page => params[:npage])
      @subscribed = @client.list
    else
      session[:notice] = _('The mailing list external server is offline.')
      redirect_to action: :index
    end
  end
end
