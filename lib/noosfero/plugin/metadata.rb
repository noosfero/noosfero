require_relative 'custom_data'

class Noosfero::Plugin::Metadata < Noosfero::Plugin::CustomData

  def data_field_name
    'metadata'
  end

  def metadata
    @base.send(:metadata)["#{@plugin.public_name}_plugin"] ||= {}
  end

  def get_custom_data(name)
    if metadata[name.to_s].nil?
      get_custom_value(name)
    else
      metadata[name.to_s]
    end
  end

  def set_custom_data(name, value, type = nil)
    metadata[name.to_s] = value
  end

end
