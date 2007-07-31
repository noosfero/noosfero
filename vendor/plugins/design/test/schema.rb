ActiveRecord::Migration.verbose = false
 
ActiveRecord::Schema.define(:version => 0) do

  create_table :design_test_design_boxes, :force => true do |t|
   t.column :name,    :string
   t.column :title,    :string
   t.column :number,   :integer
   t.column :owner_type, :string
   t.column :owner_id,  :integer
  end

  create_table :design_test_design_blocks, :force => true do |t|
   t.column :name,   :string
   t.column :title,    :string
   t.column :box_id,  :integer
   t.column :position, :integer
   t.column :type,   :string
   t.column :helper,   :string
  end
 
  create_table :design_test_users, :force => true do |t|
    t.column :name, :string, :limit => 80
    t.column :design_data, :text
  end
 
end
 
ActiveRecord::Migration.verbose = true



