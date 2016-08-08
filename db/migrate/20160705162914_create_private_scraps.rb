class CreatePrivateScraps < ActiveRecord::Migration
  def change
    create_table :private_scraps do |t|
      t.references :person
      t.references :scrap
    end
  end
end
