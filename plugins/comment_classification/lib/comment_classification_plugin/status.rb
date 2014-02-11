class CommentClassificationPlugin::Status < Noosfero::Plugin::ActiveRecord

  belongs_to :owner, :polymorphic => true

  validates_presence_of :name

  named_scope :enabled, :conditions => { :enabled => true }
end
