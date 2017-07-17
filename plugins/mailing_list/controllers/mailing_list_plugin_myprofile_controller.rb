class MailingListPluginMyprofileController < MyProfileController

  before_filter :load_client
  before_filter :load_profile_settings, :only => :edit

  def edit
    @collection = @collection.no_templates.order('name ASC').paginate(:per_page => per_page, :page => params[:npage])
  end

  private

  def load_client
    begin
      @environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
      @client = MailingListPlugin::Client.new(@environment_settings)
    rescue
      session[:notice] = _('The mailing list external server is offline.')
      redirect_to profile.admin_url
    end
  end

  def per_page
    20
  end

  def load_profile_settings
    @profile_settings = Noosfero::Plugin::Settings.new profile, MailingListPlugin
  end
end
