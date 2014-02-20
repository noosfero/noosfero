class AddStiAndSerializedDataToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :type, :string
    add_column :products, :data, :text
    rename_column :products, :enterprise_id, :profile_id
  end

  def self.down
    remove_column :products, :type
    remove_column :products, :data
    rename_column :products, :profile_id, :enterprise_id
  end
end
