require_dependency 'profile'
# WORKAROUND: plugin class don't scope subclasses causing core classes conflict
require_dependency File.expand_path "#{File.dirname __FILE__}/../../lib/sniffer_plugin/profile"

class Profile

  has_one :sniffer_plugin_profile, :class_name => 'SnifferPlugin::Profile'
  has_many :sniffer_plugin_interests, :source => :product_categories, :through => :sniffer_plugin_profile
  has_many :sniffer_plugin_opportunities, :source => :opportunities, :through => :sniffer_plugin_profile

  attr_accessor :sniffer_plugin_distance

end
