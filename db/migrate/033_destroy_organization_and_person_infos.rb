class DestroyOrganizationAndPersonInfos < ActiveRecord::Migration
  def self.up
    Person.find_each do |i|
      info = ApplicationRecord.connection.select_one("select * from person_infos where person_id = #{i.id}")
      i.name = info["name"] unless info["name"].nil?
      i.address = info["address"] unless info["address"].nil?
      [ "photo", "contact_information", "birth_date", "sex", "city", "state", "country" ].each do |field|
        i.send("#{field}=", info[field])
      end
      i.save!
    end
    drop_table :person_infos

    Organization.find_each do |i|
      info = ApplicationRecord.connection.select_one("select * from organization_infos where organization_id = #{i.id}")
      [ "contact_person", "contact_email", "acronym", "foundation_year", "legal_form", "economic_activity", "management_information", "validated" ].each do |field|
        i.send("#{field}=", info[field])
      end
      i.save!
    end
    drop_table :organization_infos
  end

  def self.down
    raise "this migration can't be reverted"
  end
end
