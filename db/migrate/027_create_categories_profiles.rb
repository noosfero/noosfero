class CreateCategoriesProfiles < ActiveRecord::Migration
  def self.up
    create_table :categories_profiles, :id => false do |t|
      t.integer :profile_id
      t.integer :category_id
    end
  end

  def self.down
    drop_table :categories_profiles
  end
end
