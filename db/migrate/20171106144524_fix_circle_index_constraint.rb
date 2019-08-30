class FixCircleIndexConstraint < ActiveRecord::Migration[4.2]
  def change
    remove_index :circles, name: "circles_composite_key_index"
    add_index :circles, [:person_id, :name, :profile_type], name: "circles_composite_key_index", unique: true
  end
end
