class GoogleMaps

  extend ActionView::Helpers::TagHelper

  class << self

    def erase_config
      @config = nil
    end

    def config_file
      File.join(RAILS_ROOT, 'config', 'web2.0.yml')
    end

    def config
      if @config.nil?
        if File.exists?(config_file)
          yaml = YAML.load_file(config_file)
          @config = yaml['googlemaps']
        end
      end

      @config ||= {}
    end

    def enabled?
      !config['key'].nil?
    end

    def key
      config['key']
    end

    def initial_zoom
      config['initial_zoom'] || 4
    end

    def api_url
      "http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{key}"
    end

  end
end
