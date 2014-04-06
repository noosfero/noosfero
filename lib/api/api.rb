require 'grape'

module API
  class API < Grape::API
    version 'v1'
    prefix "api"
    format :json
    content_type :txt, "text/plain"

    mount V1::Articles
    mount V1::Comments

#    helpers APIHelpers

#    require Articles
 
  end
end
