class GoogleMaps

  extend ActionView::Helpers::TagHelper

  class << self

    include ApplicationHelper

    def enabled?(domain)
      domain = Domain.find_by_name(domain)
      domain ? !domain.google_maps_key.nil? : false
    end

    def key(domainname)
      domain = Domain.find_by_name(domainname)
      domain && domain.google_maps_key || ''
    end

    def initial_zoom
      NOOSFERO_CONF['googlemaps_initial_zoom'] || 4
    end

    def api_url(domain)
      "http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{key(domain)}"
    end

  end
end
