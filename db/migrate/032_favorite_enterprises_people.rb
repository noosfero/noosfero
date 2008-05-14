class FavoriteEnterprisesPeople < ActiveRecord::Migration
  def self.up
    create_table :favorite_enteprises_people, :id => false do |t|
      t.integer :person_id
      t.integer :enterprise_id
    end
  end

  def self.down
    drop_table :favorite_enteprises_people
  end
end
