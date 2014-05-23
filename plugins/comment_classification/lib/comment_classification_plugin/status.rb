class CommentClassificationPlugin::Status < Noosfero::Plugin::ActiveRecord

  belongs_to :owner, :polymorphic => true

  attr_accessible :name, :enabled

  validates_presence_of :name

  scope :enabled, :conditions => { :enabled => true }
end
