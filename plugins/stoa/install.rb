require 'fileutils'

config_path = File.join('plugins', 'stoa', 'config.yml')
config_template = File.join('plugins', 'stoa', 'config.yml.dist')
FileUtils.cp(config_template, config_path) if !File.exist?(config_path)
