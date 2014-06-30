require 'fileutils'

config_path = File.join(File.dirname(__FILE__), 'config.yml')
config_template = File.join(File.dirname(__FILE__), 'config.yml.dist')
FileUtils.cp(config_template, config_path) if !File.exist?(config_path)
