class CreatePushSubscriptions < ActiveRecord::Migration
  def change
    create_table :push_subscriptions do |t|
      t.string  :endpoint, null: false
      t.jsonb   :keys, default: {}, null: false
      t.integer :owner_id
      t.string  :owner_type
      t.integer :environment_id, null: false
      t.timestamps
    end
  end
end
