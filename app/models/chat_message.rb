class ChatMessage < ApplicationRecord

  attr_accessible :body, :from, :to

  belongs_to :to, :class_name => 'Profile'
  belongs_to :from, :class_name => 'Profile'

  validates_presence_of :from, :to
end
