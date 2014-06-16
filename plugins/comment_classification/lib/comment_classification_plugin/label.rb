class CommentClassificationPlugin::Label < Noosfero::Plugin::ActiveRecord

  belongs_to :owner, :polymorphic => true

  validates_presence_of :name

  scope :enabled, :conditions => { :enabled => true }

  attr_accessible :name, :enabled, :color

  COLORS = ['red', 'green', 'yellow', 'gray', 'blue']
end
