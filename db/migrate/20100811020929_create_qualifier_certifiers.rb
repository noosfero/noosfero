class CreateQualifierCertifiers < ActiveRecord::Migration
  def self.up
    create_table :qualifier_certifiers do |t|
      t.references :qualifier
      t.references :certifier
    end
  end

  def self.down
    drop_table :qualifier_certifiers
  end
end
