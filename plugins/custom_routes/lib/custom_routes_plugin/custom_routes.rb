class CustomRoutesPlugin::CustomRoutes
  def self.load
    return unless CustomRoutesPlugin::Route.table_exists?

    Noosfero::Application.routes.draw do
      CustomRoutesPlugin::Route.where(enabled: true).each do |route|
        # TODO: also set query params? Maybe using a controller before_action
        route_hash = Rails.application.routes.recognize_path(route.target_url)
        get route.source_url, route_hash
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
