class MailingSent < ActiveRecord::Base
  belongs_to :mailing
  belongs_to :person
end
