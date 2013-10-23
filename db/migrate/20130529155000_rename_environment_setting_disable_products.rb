class RenameEnvironmentSettingDisableProducts < ActiveRecord::Migration
  def self.up
    select_all("select id from environments").each do |environment|
      env = Environment.find(environment['id'])
      env.settings[:products_for_enterprises_enabled] =
         !env.settings[:disable_products_for_enterprises_enabled]
      env.settings.delete :disable_products_for_enterprises_enabled
      env.save!
    end
  end

  def self.down
    select_all("select id from environments").each do |environment|
      env = Environment.find(environment['id'])
      env.settings[:disable_products_for_enterprises_enabled] =
         !env.settings[:products_for_enterprises_enabled]
      env.settings.delete :products_for_enterprises_enabled
      env.save!
    end
  end
end
