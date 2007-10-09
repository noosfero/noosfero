require 'noosfero'

# This module defines utility methods for generating URL's in contexts where
# one does not have a request (i.e. ActionMailer classes like TaskMailer).
#
# TODO: document the use of config/web.yml in a INSTALL document
module Noosfero::URL

  class << self

    def config
      if @config.nil?
        config_file = File.join(RAILS_ROOT, 'config', 'web.yml')
        if File.exists?(config_file)
          @config = YAML::load_file(config_file)
        else
          @config = {
            'path' => '',
            'port' => 3000
          }
        end
      end

      @config
    end
  end

  def port
    Noosfero::URL.config['port']
  end

  def path
    Noosfero::URL.config['path']
  end

end
