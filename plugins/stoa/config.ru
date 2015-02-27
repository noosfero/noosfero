require ::File.expand_path('../../../config/environment',  __FILE__)
require 'stoa_plugin'
require 'stoa_plugin/auth'

run StoaPlugin::Auth
