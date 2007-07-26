class CreateAffiliations < ActiveRecord::Migration
  def self.up
    create_table :affiliations do |t|
      t.column :user_id,         :integer
      t.column :enterprise_id,   :integer
    end
  end

  def self.down
    drop_table :affiliations
  end
end
