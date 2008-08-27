class AddEditAppearancePermission < ActiveRecord::Migration

  def self.up
    [ Profile::Roles.admin, Environment::Roles.admin].each do |item|
      item.permissions += [ 'edit_appearance' ]
      item.save!
    end
  end

  def self.down
    [ Profile::Roles.admin, Environment::Roles.admin].each do |item|
      item.permissions -= [ 'edit_appearance' ]
      item.save!
    end
  end
end
