class MoveReferenceFromImageToOwners < ActiveRecord::Migration
  def self.up
    %w[ profiles categories products tasks ].each do |table|
      type = table.singularize.camelcase
      add_column table, :image_id, :integer
      update("update #{table} set image_id = (select i.id from images i where i.owner_id = #{table}.id and i.owner_type = '#{type}' limit 1) where id in (select owner_id from images where owner_type = '#{type}' and owner_id is not null)")
    end
    remove_column :images, :owner_id
    remove_column :images, :owner_type
  end

  def self.down
    add_column :images, :owner_id, :integer
    add_column :images, :owner_type, :string
    %w[ profiles products categories tasks ].each do |table|
      type = table.singularize.camelcase
      update("update images set owner_id = (select id from #{table} origin where origin.image_id = images.id), owner_type = '#{type}' where id in (select image_id from #{table} where image_id is not null)")
      remove_column table, :image_id
    end
  end
end
