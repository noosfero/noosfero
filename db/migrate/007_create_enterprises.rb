class CreateEnterprises < ActiveRecord::Migration
  def self.up
    create_table :enterprises do |t|
      t.column :address,                 :string
      t.column :contact_phone,           :string
      t.column :contact_person,          :string
      t.column :acronym,                 :string
      t.column :foundation_year,         :integer, :limit => 4
      t.column :legal_form,              :string
      t.column :economic_activity,       :string
      t.column :management_information,  :string
      t.column :active,                  :boolean, :default => "false"
    end
  end

  def self.down
    drop_table :enterprises
  end
end
