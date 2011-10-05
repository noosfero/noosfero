enabled_plugins = Dir.glob(File.join(Rails.root, 'config', 'plugins', '*')).map {|path| File.basename(path)}.reject {|a| a == "README"}
sh './script/noosfero-plugins disableall'
require File.join(File.dirname(__FILE__), '../../config/environment.rb')
enabled_plugins.each do |plugin|
  sh "./script/noosfero-plugins enable #{plugin}"
end
