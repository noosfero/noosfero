class User < ActiveRecord::Base
  has_many :boxes, :as => :owner
end
