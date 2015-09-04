class CreateFbAppPageTabConfig < ActiveRecord::Migration

  def change
    create_table :fb_app_plugin_page_tab_configs do |t|
      t.string :page_id
      t.text :config, default: {}.to_yaml
      t.integer :profile_id

      t.timestamps
    end
    add_index :fb_app_plugin_page_tab_configs, [:profile_id]
    add_index :fb_app_plugin_page_tab_configs, [:page_id]
    add_index :fb_app_plugin_page_tab_configs, [:page_id, :profile_id]
  end

end
