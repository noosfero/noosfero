class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.string :type
      t.string :subject
      t.text :body
      t.integer :source_id
      t.string :source_type
      t.references :person
      t.string :locale
      t.timestamps
    end
  end

  def self.down
    drop_table :mailings
  end
end
