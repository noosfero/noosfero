class GoogleMaps

  extend ActionView::Helpers::TagHelper

  class << self

    include ApplicationHelper

    def erase_config
      @config = nil
    end

    def config
      @config = web2_conf['googlemaps'] if @config.nil?
      @config ||= {}
    end

    def enabled?
      !config['key'].nil?
    end

    def key
      config['key'] || ''
    end

    def initial_zoom
      config['initial_zoom'] || 4
    end

    def api_url
      "http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{key}"
    end

  end
end
