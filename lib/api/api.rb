require 'grape'
Dir["#{Rails.root}/lib/api/*.rb"].each {|file| require file}

module API
  class API < Grape::API
    version 'v1'
    prefix "api"
    format :json
    content_type :txt, "text/plain"

    helpers APIHelpers
 
    mount V1::Articles
    mount V1::Comments
    mount V1::Users
    mount Session

  end
end
