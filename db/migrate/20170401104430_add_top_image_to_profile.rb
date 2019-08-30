class AddTopImageToProfile < ActiveRecord::Migration[4.2]
  def self.up
    add_column :profiles, :top_image_id, :integer
  end

  def self.down
    remove_column :profiles, :top_image_id
  end
end
