class AddsTypeToExternalPerson < ActiveRecord::Migration
  def up
    add_column :external_people, :type, :string
  end

  def down
    remove_column :external_people, :type
  end
end
