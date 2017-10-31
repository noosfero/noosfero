class SecureFilenames < ActiveRecord::Migration
  def up
    UploadedFile.find_each do |file|
      next if file.filename == file.filename.to_slug
      begin
        file.filename = file.filename.to_slug
        file.thumbnails_processed = false
        file.save!
        file.create_thumbnails if file.thumbnailable?
      rescue
        # Nothing can be done
      end
    end
  end
end
