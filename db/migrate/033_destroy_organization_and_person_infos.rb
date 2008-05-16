class DestroyOrganizationAndPersonInfos < ActiveRecord::Migration
  def self.up
    Person.find(:all).each do |i|
      i.name = i.info.name unless i.info.name.nil?
      i.address = i.info.address unless i.info.address.nil?
      for field in [ :photo, :contact_information, :birth_date, :sex, :city, :state, :country ] do
        i.send("#{field}=", i.info.send(field))
      end
      i.save!
    end
    drop_table :person_infos

    Organization.find(:all).each do |i|
      for field in [ :contact_person, :contact_email, :acronym, :foundation_year, :legal_form, :economic_activity, :management_information, :validated ] do
        i.send("#{field}=", i.info.send(field))
      end
      i.save!
    end
    drop_table :organization_infos
  end

  def self.down
    raise "this migration can't be reverted"
  end
end
