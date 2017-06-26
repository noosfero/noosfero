class CustomRoutesPlugin::CustomRoutes
  def self.load
    return unless CustomRoutesPlugin::Route.table_exists?

    Noosfero::Application.routes.draw do
      CustomRoutesPlugin::Route.where(enabled: true).each do |route|
        begin
          # TODO: also set query params? Maybe using a controller before_action
          get route.source_url, route.metadata.symbolize_keys
        rescue
          # ignore possible invalid routes, so the startup doesn't break
        end
      end
    end
  end

  def self.reload
    begin
      Noosfero::Application.routes_reloader.reload!
    rescue ActionController::RoutingError => e
      nil
    end
  end

end
