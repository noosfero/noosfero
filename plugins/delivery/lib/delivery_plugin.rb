module DeliveryPlugin
  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t("delivery_plugin.lib.plugin.name")
  end

  def self.plugin_description
    I18n.t("delivery_plugin.lib.plugin.description")
  end
end
