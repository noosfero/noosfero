class RemovePublishContentPermissionFromRoles < ActiveRecord::Migration[5.1]
  def change
    Role.all.each do |role|
        role.permissions.delete("publish_content")
        role.save!
    end
  end
end
