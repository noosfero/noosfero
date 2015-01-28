class AddEditRawHtmlBlockToAdminRole < ActiveRecord::Migration
  def self.up
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions << 'edit_raw_html_block'
      role.save!
    end
  end

  def self.down
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions -= ['edit_raw_html_block']
      role.save!
    end
  end
end
