class CreateBoxes < ActiveRecord::Migration
  def self.up
    create_table :boxes do |t|
      t.column :name,       :string
      t.column :number,     :integer
      t.column :owner_type, :string
      t.column :owner_id,   :integer
    end
  end

  def self.down
    drop_table :boxes
  end
end
