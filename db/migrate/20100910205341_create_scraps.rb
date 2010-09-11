class CreateScraps < ActiveRecord::Migration
  def self.up
    create_table :scraps do |t|
      t.text :content
      t.integer :sender_id, :receiver_id
      t.integer :scrap_id
      t.timestamps
    end
  end

  def self.down
    drop_table :scraps
  end
end
