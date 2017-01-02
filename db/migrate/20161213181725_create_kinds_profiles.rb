class CreateKindsProfiles < ActiveRecord::Migration
  def change
    create_table :kinds_profiles do |t|
      t.references :kind
      t.references :profile
    end
  end
end
