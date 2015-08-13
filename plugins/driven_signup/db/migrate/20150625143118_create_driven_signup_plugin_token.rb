class CreateDrivenSignupPluginToken < ActiveRecord::Migration

  def change
    create_table :driven_signup_plugin_auths do |t|
      t.integer :environment_id
      t.string :name
      t.string :token

      t.timestamps
    end
    add_index :driven_signup_plugin_auths, :environment_id
    add_index :driven_signup_plugin_auths, :token
    add_index :driven_signup_plugin_auths, [:environment_id, :token]
  end

end
