ActiveRecord::Migration.verbose = false
 
ActiveRecord::Schema.define(:version => 0) do

  create_table :access_control_test_roles, :force => true do |t|
   t.column :name,        :string
   t.column :permissions, :string
  end

  create_table :access_control_test_role_assignments, :force => true do |t|
   t.column :role_id,       :integer
   t.column :accessor_id,   :integer
   t.column :accessor_type, :string
   t.column :resource_id,   :integer
   t.column :resource_type, :string
   t.column :is_global,     :boolean
  end
 
  create_table :access_control_test_accessors, :force => true do |t|
    t.column :name, :string
  end  
  
  create_table :access_control_test_resources, :force => true do |t|
    t.column :name, :string
  end
end
 
ActiveRecord::Migration.verbose = true



