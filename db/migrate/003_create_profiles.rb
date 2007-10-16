class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name,              :string
      t.column :type,              :string
      t.column :identifier,        :string
      t.column :environment_id,    :integer
      t.column :design_data, :text


      t.column :active,            :boolean, :default => true
      t.column :address,           :string
      t.column :contact_phone,     :string
          
      #person fields
      t.column :user_id,           :integer

      #enterprise fields
      t.column :region_id,         :integer

    end
  end

  def self.down
    drop_table :profiles
  end
end
