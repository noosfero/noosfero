class AddSendEmailPluginConfigToEnvironment < ActiveRecord::Migration[5.1]
  def self.up
    add_column :environments, :send_email_plugin_allow_to, :text
  end

  def self.down
    remove_column :environments, :send_email_plugin_allow_to
  end
end
