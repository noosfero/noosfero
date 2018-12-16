class AddCommentsCountToProfile < ActiveRecord::Migration[5.1]
  def self.up
    change_table :profiles do |t|
      t.integer :comments_count
    end
  end

  def self.down
    remove_column :profiles, :comments_count
  end
end