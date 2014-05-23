class MailingSent < ActiveRecord::Base
  attr_accessible :person
  belongs_to :mailing
  belongs_to :person
end
