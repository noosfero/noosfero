class CommentClassificationPlugin::Label < Noosfero::Plugin::ActiveRecord

  belongs_to :owner, :polymorphic => true

  validates_presence_of :name

  named_scope :enabled, :conditions => { :enabled => true }

  COLORS = ['red', 'green', 'yellow', 'gray', 'blue']
end
