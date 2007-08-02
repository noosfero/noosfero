class CreateAffiliations < ActiveRecord::Migration
  def self.up
    create_table :affiliations do |t|
      t.column :person_id,            :integer
      t.column :organization_id,      :integer
    end
  end

  def self.down
    drop_table :affiliations
  end
end
