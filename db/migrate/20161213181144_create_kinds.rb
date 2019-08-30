class CreateKinds < ActiveRecord::Migration[4.2]
  def change
    create_table :kinds do |t|
      t.string :name
      t.string :type
      t.boolean :moderated, default: false
      t.references :environment
    end
  end
end
