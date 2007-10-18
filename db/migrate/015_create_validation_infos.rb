class CreateValidationInfos < ActiveRecord::Migration
  def self.up
    create_table :validation_infos do |t|
      t.column :validation_methodology, :text
      t.column :restrictions, :text

      # foreign keys
      t.column :organization_id, :integer
    end
  end

  def self.down
    drop_table :validation_infos
  end
end
