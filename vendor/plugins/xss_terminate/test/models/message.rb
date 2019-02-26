class Message < ActiveRecord::Base
  belongs_to :person, optional: true

  xss_terminate only: [ :body ]
end
