class AddCroppedImageToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :cropped_image, :string
  end
end
