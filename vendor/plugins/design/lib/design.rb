require 'design/fixed_design_holder'
require 'design/proxy_design_holder'

require 'design/helper'
require 'design/editor'

module Design

  # gets the Design object for this controller
  def design
    @design_plugin_data ||= Hash.new
    data = @design_plugin_data

    return data[:design] if data.has_key?(:design)

    config = self.class.instance_variable_get("@design_plugin_config")

    if config.has_key?(:holder)
      holder_variable_name = config[:holder]
      data[:design] = Design::ProxyDesignHolder.new(self.instance_variable_get("@#{holder_variable_name}"))
    else
      options = (config[:fixed].kind_of? Hash) ? config[:fixed] : {}
      data[:design] = Design::FixedDesignHolder.new(options)
    end

    data[:design] # redundant, but makes more clear the return value
  end
  protected :design
end
