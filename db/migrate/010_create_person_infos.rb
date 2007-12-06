class CreatePersonInfos < ActiveRecord::Migration
  def self.up
    create_table :person_infos do |t|
      t.column :name,                :string
      t.column :photo,               :text
      t.column :contact_information, :text
      t.column :birth_date,          :date
      t.column :sex,                 :string
      t.column :address,             :text
      t.column :city,                :string
      t.column :state,               :string
      t.column :country,             :string

      t.column :created_at,          :datetime
      t.column :updated_at,          :datetime
      t.column :person_id,           :integer
    end
  end

  def self.down
    drop_table :person_infos
  end
end
