class CreateQualifiers < ActiveRecord::Migration
  def self.up
    create_table :qualifiers do |t|
      t.string :name
      t.references :environment

      t.timestamps
    end
  end

  def self.down
    drop_table :qualifiers
  end
end
