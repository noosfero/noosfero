class MoveTitleVirtualFieldToNameInUploadedFile < ActiveRecord::Migration
  def self.up
    UploadedFile.find_each do |uploaded_file|
      uploaded_file.name = uploaded_file.setting.delete(:title)
      UploadedFile.update_all({:setting => uploaded_file.setting.to_yaml, :name => uploaded_file.name}, 
                              "id = #{uploaded_file.id}")
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
