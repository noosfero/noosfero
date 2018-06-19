class MailingSent < ApplicationRecord

  attr_accessible :person
  belongs_to :mailing, optional: true
  belongs_to :person, optional: true
end
