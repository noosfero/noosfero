class ChangeCircleNameIndex < ActiveRecord::Migration
  def up
  	remove_index :circles, :name => "circles_composite_key_index"
  	add_index :circles, [:person_id, :name, :profile_type], :name => "circles_composite_key_index", :unique => true
  end

  def down
  	remove_index :circles, :name => "circles_composite_key_index"
  	add_index :circles, [:person_id, :name], :name => "circles_composite_key_index", :unique => true
  end
end
