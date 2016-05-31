class ChangeNotificationRelationToPolymorphic < ActiveRecord::Migration
  def up
    rename_column(:environment_notifications, :environment_id, :target_id)
    add_column(:environment_notifications, :target_type, :string)

    execute("UPDATE environment_notifications SET target_type = 'Environment'")
  end

  def down
    rename_column(:environment_notifications, :target_id, :environment_id)
    remove_column(:environment_notifications, :target_type)
  end
end
