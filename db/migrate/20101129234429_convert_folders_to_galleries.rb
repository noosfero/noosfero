class ConvertFoldersToGalleries < ActiveRecord::Migration
  def self.up
    select_all("select id, setting from articles where type = 'Folder'").each do |folder|
      view_as = YAML.load(folder['setting'] || {}.to_yaml)[:view_as]
      update("update articles set type = 'Gallery' where id = %d" % folder['id']) if view_as == 'image_gallery'
    end
  end

  def self.down
    select_all("select id, setting from articles where type = 'Gallery'").each do |folder|
      settings = YAML.load(folder['setting'] || {}.to_yaml)
      settings[:view_as] = 'image_gallery'
      assignments = ApplicationRecord.sanitize_sql_for_assignment(:setting => settings.to_yaml)
      update("update articles set %s, type = 'Folder' where id = %d" % [assignments, folder['id']])
    end
  end
end
