class CreateProfileFollowersTable < ActiveRecord::Migration
  def up
    create_table :profiles_circles do |t|
      t.column :profile_id, :integer
      t.column :circle_id, :integer
      t.timestamps
    end

    create_table :circles do |t|
      t.column :name, :string
      t.belongs_to :person
      t.column :profile_type, :string, :null => false
    end

    add_foreign_key :profiles_circles, :circles, :on_delete => :cascade

    add_index :profiles_circles, [:profile_id, :circle_id], :name => "profiles_circles_composite_key_index", :unique => true
    add_index :circles, [:person_id, :name], :name => "circles_composite_key_index", :unique => true

    #insert one category for each friend group a person has
    execute("INSERT INTO circles(name, person_id, profile_type) SELECT DISTINCT 'friendships', f.person_id, 'Person' FROM friendships as f WHERE f.group IS NULL OR f.group = ''")
    execute("INSERT INTO circles(name, person_id, profile_type) SELECT DISTINCT regexp_split_to_table(f.group, ', '), f.person_id, 'Person' FROM friendships as f WHERE f.group IS NOT NULL AND f.group <> ''")
    #insert 'memberships' category if a person is in a community as any role
    execute("INSERT INTO circles(name, person_id, profile_type) SELECT DISTINCT 'memberships', ra.accessor_id, 'Community'  FROM role_assignments as ra JOIN profiles ON ra.resource_id = profiles.id WHERE ra.resource_type = 'Profile' AND profiles.type = 'Community'")
    #insert 'favorites' category if a person has any favorited enterprise
    execute("INSERT INTO circles(name, person_id, profile_type) SELECT DISTINCT 'favorites', person_id, 'Enterprise' FROM favorite_enterprise_people")

    #insert a follower entry for each friend, with the category the same as the friendship group or equals 'friendships'
    execute("INSERT INTO profiles_circles(profile_id, circle_id) SELECT DISTINCT f.friend_id, c.id FROM friendships as f JOIN circles as c ON f.person_id = c.person_id WHERE c.name = ANY(regexp_split_to_array(f.group, ', ')) OR c.name = 'friendships'")
    #insert a follower entry for each favorited enterprise, with the category 'favorites'
    execute("INSERT INTO profiles_circles(profile_id, circle_id) SELECT DISTINCT f.enterprise_id, c.id FROM favorite_enterprise_people AS f JOIN circles as c ON f.person_id = c.person_id WHERE c.name = 'favorites' ")
    #insert a follower entry for each community a person participates with any role
    execute("INSERT INTO profiles_circles(profile_id, circle_id) SELECT DISTINCT ra.resource_id, c.id FROM role_assignments as ra JOIN profiles ON ra.accessor_id = profiles.id JOIN circles as c ON ra.accessor_id = c.person_id WHERE ra.resource_type = 'Profile' AND profiles.type = 'Community' AND c.name = 'memberships'")
  end

  def down
    remove_foreign_key :profiles_circles, :circles
    remove_index :profiles_circles, :name => "profiles_circles_composite_key_index"
    remove_index :circles, :name => "circles_composite_key_index"
    drop_table :circles
    drop_table :profiles_circles
  end
end
