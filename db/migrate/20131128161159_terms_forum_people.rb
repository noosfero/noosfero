class TermsForumPeople < ActiveRecord::Migration
  def self.up
    create_table :terms_forum_people, :id => false do |t|
      t.integer :forum_id
      t.integer :person_id
    end
    add_index :terms_forum_people, [:forum_id, :person_id]
  end

  def self.down
    remove_index :terms_forum_people, [:forum_id, :person_id]
    drop_table :terms_forum_people
  end

end