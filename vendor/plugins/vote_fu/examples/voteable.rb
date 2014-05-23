class Voteable < ActiveRecord::Base

  belongs_to :user
  
  acts_as_voteable
  
  scope :descending, :order => "created_at DESC"

  
end