class MailingSent < ApplicationRecord

  attr_accessible :person
  belongs_to :mailing
  belongs_to :person
end
