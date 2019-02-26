class ChatMessage < ApplicationRecord

  attr_accessible :body, :from, :to

  belongs_to :to, class_name: 'Profile', optional: true
  belongs_to :from, class_name: 'Profile', optional: true

  validates_presence_of :from, :to
end
