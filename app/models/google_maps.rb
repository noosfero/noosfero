class GoogleMaps

  extend ActionView::Helpers::TagHelper

  class << self

    def config_file
      File.join(RAILS_ROOT, 'config', 'web2.0.yml')
    end

    def enabled?
      File.exists?(config_file)
    end

    def key
      if enabled?
        config = YAML.load_file(config_file)
        if config.has_key?(:googlemaps)
          config[:googlemaps][:key]
        else
          nil
        end
      else
        nil
      end
    end

    def api_url
      "http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{key}"
    end

  end
end
