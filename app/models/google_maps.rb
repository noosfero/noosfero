class GoogleMaps

  extend ActionView::Helpers::TagHelper

  class << self

    include ApplicationHelper

    def erase_config
      @config = nil
    end

    def config
      @config ||= (web2_conf['googlemaps'] || {})
    end

    def enabled?(domain)
      domain = Domain.find_by_name(domain)
      domain ? !domain.google_maps_key.nil? : false
    end

    def key(domain)
      Domain.find_by_name(domain).google_maps_key || ''
    end

    def initial_zoom
      config['initial_zoom'] || 4
    end

    def api_url(domain)
      "http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{key(domain)}"
    end

  end
end
