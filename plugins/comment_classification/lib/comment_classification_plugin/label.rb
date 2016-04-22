class CommentClassificationPlugin::Label < ApplicationRecord

  belongs_to :owner, :polymorphic => true

  validates_presence_of :name

  scope :enabled, -> { where enabled: true }

  attr_accessible :name, :enabled, :color

  COLORS = ['red', 'green', 'yellow', 'gray', 'blue']

end
