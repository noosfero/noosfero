class Review < ActiveRecord::Base
  belongs_to :person, optional: true
  
  xss_terminate html5lib_sanitize: [:body, :extended]
end
