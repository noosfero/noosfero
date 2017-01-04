class AddTopImageToProfile < ActiveRecord::Migration

  def self.up
    add_column :profiles, :top_image_id, :integer
  end

  def self.down
    remove_column :profiles, :top_image_id
  end

end
