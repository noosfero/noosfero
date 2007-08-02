class CreateOrganizationInfos < ActiveRecord::Migration
  def self.up
    create_table :organization_infos do |t|
      t.column :organization_id,           :integer
      t.column :contact_person,            :string
      t.column :acronym,                   :string
      t.column :foundation_year,           :integer, :limit => 4
      t.column :legal_form,                :string
      t.column :economic_activity,         :string
      t.column :management_information,    :string
    end
  end

  def self.down
    drop_table :organization_infos
  end
end
