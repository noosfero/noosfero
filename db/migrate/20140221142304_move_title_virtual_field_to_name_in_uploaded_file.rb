class MoveTitleVirtualFieldToNameInUploadedFile < ActiveRecord::Migration
  def self.up
    UploadedFile.find_each do |uploaded_file|
      uploaded_file.name = uploaded_file.setting.delete :title
      uploaded_file.send :update_without_callbacks
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
