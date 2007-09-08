class CreatePersonInfos < ActiveRecord::Migration
  def self.up
    create_table :person_infos do |t|
      t.column :photo, :text
      t.column :address, :text
      t.column :contact_information, :text
    end
  end

  def self.down
    drop_table :person_infos
  end
end
