module FbAppPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t 'fb_app_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'fb_app_plugin.lib.plugin.description'
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.test_users
    @test_users ||= self.config[:test_users]
  end
  def self.test_user? user
    user and (self.test_users.blank? or self.test_users.include? user.identifier)
  end

  def self.debug? actor=nil
    self.test_user? actor
  end

  def self.scope user
    if self.test_user? user then 'publish_actions' else '' end
  end

  def self.oauth_provider_for environment
    return unless self.config.present?

    @oauth_providers ||= {}
    @oauth_providers[environment] ||= begin
      app_id = self.timeline_app_credentials[:id].to_s
      app_secret = self.timeline_app_credentials[:secret].to_s

      client = environment.oauth_providers.where(client_id: app_id).first
      # attributes that may be changed by the user
      client ||= OauthClientPlugin::Provider.new strategy: 'facebook',
        name: 'FB App', site: 'https://facebook.com'

      # attributes that should not change
      client.attributes = {
        client_id: app_id, client_secret: app_secret,
        environment_id: environment.id,
      }
      client.save! if client.changed?

      client
    end
  end

  def self.open_graph_config
    return unless self.config.present?

    @open_graph_config ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.config[key][:open_graph]
    end
  end

  def self.credentials app = :app
    return unless self.config.present?
    {id: self.config[app][:id], secret: self.config[app][:secret]}
  end

  def self.timeline_app_credentials
    return unless self.config.present?
    @timeline_app_credentials ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.credentials key
    end
  end

  def self.page_tab_app_credentials
    return unless self.config.present?
    @page_tab_app_credentials ||= begin
      key = if self.config[:page_tab][:use_test_app] then :test_app else :app end
      self.credentials key
    end
  end

end

