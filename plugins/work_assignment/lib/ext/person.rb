require_dependency 'person'

class Person
  def build_email_contact(params = {})
    EmailContact.new(params.merge(:name => name, :email => email, :sender => self))
  end
end