class CreatePersonInfos < ActiveRecord::Migration
  def self.up
    create_table :person_infos do |t|
      t.column :name, :string
      t.column :photo, :text
      t.column :address, :text
      t.column :contact_information, :text

      t.column :person_id, :integer
    end
  end

  def self.down
    drop_table :person_infos
  end
end
