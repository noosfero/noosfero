class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name,                                   :string
      t.column :identifier,                             :string
      t.column :virtual_community_id,                   :integer
      t.column :flexible_template_template,             :string, :default => "default"
      t.column :flexible_template_theme,                :string, :default => "default"
      t.column :flexible_template_icon_theme,           :string, :default => "default"
      t.column :active,                                 :boolean, :default => "false"
      
      #person fields
      t.column :user_id,                                :integer
      
      #enterprise fields
      t.column :address,                                :string
      t.column :contact_phone,                          :string
      t.column :contact_person,                         :string
      t.column :acronym,                                :string
      t.column :foundation_year,                        :integer, :limit => 4
      t.column :legal_form,                             :string
      t.column :economic_activity,                      :string
      t.column :management_information,                 :string

    end
  end

  def self.down
    drop_table :profiles
  end
end
