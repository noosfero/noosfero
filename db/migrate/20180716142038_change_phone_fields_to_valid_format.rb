class ChangePhoneFieldsToValidFormat < ActiveRecord::Migration
  def change
    Person.find_each do |person|
      unless person.valid?
        Person::PHONE_FIELDS.each do |field|
          phone = person.send(field)
          if phone.present? && phone !~ Person::PHONE_FORMAT
            field = field.to_s + "="
            phone = phone.gsub(/\D/, '')
            phone = phone.rjust(5, '0') if phone.length < 5
            phone = phone[0, 15] if phone.length > 15
            person.send(field, phone)
          end
        end
        p person.name
        person.save(validate: false)
      end
    end
  end
end
