class SubOrganizationsPlugin::ApprovePaternityRelation < Noosfero::Plugin::ActiveRecord
  belongs_to :task
  belongs_to :parent, :polymorphic => true
  belongs_to :child, :polymorphic => true

  validates_presence_of :task, :parent, :child

  attr_accessible :task, :parent, :child

  class << self
    def parent_approval(task)
      find_by_task_id(task.id).parent
    end
  end

end
