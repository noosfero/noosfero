class AddIdToFavoriteEnterprisesPeople < ActiveRecord::Migration
  def up
    rename_table :favorite_enteprises_people, :favorite_enterprise_people

    change_table :favorite_enterprise_people do |t|
      t.timestamps
    end
    add_column :favorite_enterprise_people, :id, :primary_key

    add_index :favorite_enterprise_people, [:person_id, :enterprise_id]
    add_index :favorite_enterprise_people, :person_id
    add_index :favorite_enterprise_people, :enterprise_id
  end

  def down
    rename_table :favorite_enterprise_people, :favorite_enteprises_people

    remove_column :favorite_enteprises_people, :id
    remove_column :favorite_enteprises_people, :created_at
    remove_column :favorite_enteprises_people, :updated_at

    remove_index :favorite_enteprises_people, [:person_id, :enterprise_id]
    remove_index :favorite_enteprises_people, :person_id
    remove_index :favorite_enteprises_people, :enterprise_id
  end
end
