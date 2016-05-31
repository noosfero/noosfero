class CommentClassificationPlugin::Status < ApplicationRecord

  belongs_to :owner, :polymorphic => true

  attr_accessible :name, :enabled

  validates_presence_of :name

  scope :enabled, -> { where enabled: true }

end
