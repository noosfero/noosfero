$: << File.expand_path("..", __FILE__)

module JRails

  @@config = {
    :google           => false,
    :jquery_version   => "1.7.2",
    :jqueryui_version => "1.9.1",
    :compressed       => true
  }

  JQUERY_VAR = 'jQuery'

  def self.load_config
    config_file = File.join("./", "config", "jrails.yml")
    if File.exist? config_file
      loaded_config = YAML.load_file(config_file)
      if loaded_config and loaded_config.key? Rails.env
        @@config.merge!(loaded_config[Rails.env].symbolize_keys)
        if google?
          @@jquery_path   = "http://ajax.googleapis.com/ajax/libs/jquery/#{@@config[:jquery_version]}/jquery#{".min" if compressed?}.js"
          @@jqueryui_path = "http://ajax.googleapis.com/ajax/libs/jqueryui/#{@@config[:jqueryui_version]}/jquery-ui#{".min" if compressed?}.js"
          @@jqueryui_i18n_path = "http://ajax.googleapis.com/ajax/libs/jqueryui/#{@@config[:jqueryui_version]}/i18n/jquery-ui-i18n#{".min" if compressed?}.js"
        end
      else
        raise Exception.new "Failed finding '#{Rails.env}' environment in config. check your 'config/jrails.yml' or delete that file "
      end
    end
  end

  def self.config        ; @@config              ; end
  def self.google?       ; @@config[:google]     ; end
  def self.compressed?   ; @@config[:compressed] ; end
  def self.jquery_path   ; @@jquery_path         ; end
  def self.jqueryui_path ; @@jqueryui_path       ; end
  def self.jqueryui_i18n_path ; @@jqueryui_i18n_path  ; end

end

require 'jrails/engine'
require 'jrails/selector_assertions' if Rails.env.test?

