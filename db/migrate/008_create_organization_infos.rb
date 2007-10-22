class CreateOrganizationInfos < ActiveRecord::Migration
  def self.up
    create_table :organization_infos do |t|
      t.column :organization_id,           :integer
      t.column :contact_person,            :string
      t.column :contact_email,             :string
      t.column :acronym,                   :string
      t.column :foundation_year,           :integer, :limit => 4
      t.column :legal_form,                :string
      t.column :economic_activity,         :string
      t.column :management_information,    :string
      t.column :validated,                 :boolean, :default => false
    end
  end

  def self.down
    drop_table :organization_infos
  end
end
