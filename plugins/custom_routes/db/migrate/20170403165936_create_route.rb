class CreateRoute < ActiveRecord::Migration
  def change
    create_table :custom_routes_plugin_routes do |t|
      t.integer :environment_id, null: false
      t.string :source_url, null: false, unique: true
      t.string :target_url, null: false
      t.boolean :enabled, default: true
    end
  end
end
