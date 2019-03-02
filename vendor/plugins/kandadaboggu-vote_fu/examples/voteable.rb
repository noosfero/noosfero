class Voteable < ActiveRecord::Base

  belongs_to :user, optional: true
  
  acts_as_voteable
  
  scope :descending, :order => "created_at DESC"

  
end