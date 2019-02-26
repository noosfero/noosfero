class CreateNotificationTable < ActiveRecord::Migration[5.1]
  def up
    create_table :environment_notifications do |t|
      t.text :message
      t.integer :environment_id
      t.string :type
      t.string :title
      t.boolean :active
      t.boolean :display_only_in_homepage, :default => false
      t.boolean :display_to_all_users,     :default => false
      t.boolean :display_popup,            :default => false
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end

    create_table :environment_notifications_users, id: false do |t|
      t.belongs_to :environment_notification, index: {:name => 'index_Zaem6uuw'}
      t.belongs_to :user, index: {:name => 'index_ap3nohR9'}
    end
  end

  def down
    drop_table :environment_notifications
    drop_table :environment_notifications_users
  end
end
