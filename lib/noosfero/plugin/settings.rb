require_relative 'custom_data'

class Noosfero::Plugin::Settings < Noosfero::Plugin::CustomData

  def data_field_name
    'setting'
  end

  def settings
    settings_field = @base.class.settings_field
    @base.send(settings_field)["#{@plugin.public_name}_plugin".to_sym] ||= {}
  end

  def get_custom_data(name)
    if settings[name.to_sym].nil?
      get_custom_value(name)
    else
      settings[name.to_sym]
    end
  end

  def set_custom_data(name, value, type=nil)
    if type
      value = ActsAsHavingSettings.type_cast(value, ActiveRecord::Type.const_get(type.to_s.camelize.to_sym).new)
    end
    settings[name.to_sym] = value
  end

end
