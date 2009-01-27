class AddRefuseJoinTable < ActiveRecord::Migration
  def self.up
    create_table :refused_join_community, :id => false do |t|
      t.integer :person_id
      t.integer :community_id
    end
  end

  def self.down
    drop_table :refused_join_community
  end
end
