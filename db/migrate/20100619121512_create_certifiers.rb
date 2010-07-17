class CreateCertifiers < ActiveRecord::Migration
  def self.up
    create_table :certifiers do |t|
      t.string :name
      t.string :description
      t.string :link
      t.references :environment

      t.timestamps
    end
  end

  def self.down
    drop_table :certifiers
  end
end
