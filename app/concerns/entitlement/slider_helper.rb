module Entitlement::SliderHelper
  def update_access_level(slider_level, access_kind=nil)
    access_attribute = access_kind.present? ? "#{access_kind}_access=" : 'access='
    access_level = convert_slider_to_default_level(slider_level)
    self.send(access_attribute, access_level)
  end

  def convert_slider_to_default_level(slider_level)
    levels_keys = Entitlement::Levels.range_options
    levels_access_key = levels_keys[slider_level.to_i]
    levels_access_value = Entitlement::Levels.levels[levels_access_key]
    levels_access_value
  end

  def default_slider_value(access_kind=nil)
    range = Entitlement::Levels.levels.keys
    access_attr = access_kind.present? ? "#{access_kind}_access" : 'access'
    current_access_key = Entitlement::Levels.levels.invert[self.send(access_attr)]
    current_access_index = range.index(current_access_key)
    current_access_index
  end

  def slider_levels
    data = {}
    Entitlement::Levels.levels.keys.each_with_index do |level, index|
      data[level] = index
    end
    data
  end
end
