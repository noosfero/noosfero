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

    config = self.class.design_plugin_config

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

  # returns the path to the designs directory, relative to the +public+
  # directory of your application.
  #
  # Defaults to #{RAILS_ROOT}/public/designs
  def Design.design_root
    Design.instance_variable_get('@design_root') || 'designs'
  end

  # sets the path to the designs directory.
  #
  # Passing nil resets +design_root+ to its default value.
  def Design.design_root=(dir)
    Design.instance_variable_set('@design_root', dir)
  end

  # :nodoc:
  #
  # used for testing
  def Design.public_filesystem_root
    Design.instance_variable_get('@public_filesystem_root') || File.join(RAILS_ROOT, 'public')
  end

  # :nodoc:
  #
  # used for testing
  def Design.public_filesystem_root=(value)
    Design.instance_variable_set('@public_filesystem_root', value)
  end


end
