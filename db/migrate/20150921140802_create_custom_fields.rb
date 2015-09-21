class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string :name
      t.string :format, :default => ""
      t.text :default_value, :default => ""
      t.string :customized_type
      t.text :extras, :default => ""
      t.boolean :active, :default => false
      t.boolean :required, :default => false
      t.boolean :signup, :default => false
      t.integer :environment_id
      t.timestamps
    end

    create_table :custom_field_values do |t|
      t.column "customized_type", :string, :default => "", :null => false
      t.column "customized_id", :integer, :default => 0, :null => false
      t.column "public", :boolean, :default => false, :null => false
      t.column "custom_field_id", :integer, :default => 0, :null => false
      t.column "value", :text, :default => ""
      t.timestamps
    end


    add_index :custom_field_values, ["customized_type", "customized_id","custom_field_id"], :unique => true, :name => 'index_custom_field_values'
    add_index :custom_fields, ["customized_type","name","environment_id"], :unique => true, :name => 'index_custom_field'

  end
end

