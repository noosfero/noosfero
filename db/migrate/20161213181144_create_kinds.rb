class CreateKinds < ActiveRecord::Migration
  def change
    create_table :kinds do |t|
      t.string :name
      t.string :type
      t.boolean :moderated, :default => false
      t.references :environment
    end
  end
end
