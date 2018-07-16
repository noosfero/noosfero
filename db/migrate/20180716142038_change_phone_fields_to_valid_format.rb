class ChangePhoneFieldsToValidFormat < ActiveRecord::Migration
  def change
    Person.find_each do |person|
      unless person.valid?
        Person::PHONE_FIELDS.each do |field|
          phone = person.send(field)
          if  phone.present? && person.send(field) !~ Person::PHONE_FORMAT
            field = field.to_s + "="
            person.send(field, phone.gsub(/\D/, ''))
          end
        end
        person.save!
      end
    end
  end
end
