class AddCroppedImageToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :cropped_image, :string
  end
end
