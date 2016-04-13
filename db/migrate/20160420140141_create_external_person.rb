class CreateExternalPerson < ActiveRecord::Migration
  def change
    create_table :external_people do |t|
      t.string :name
      t.string :identifier
      t.string :source
      t.string :email
      t.integer :environment_id
      t.boolean :visible, default: true
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
