class Message < ActiveRecord::Base
  belongs_to :person

  xss_terminate :only => [ :body ]
end
