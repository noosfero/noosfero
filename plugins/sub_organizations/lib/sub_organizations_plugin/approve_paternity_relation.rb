class SubOrganizationsPlugin::ApprovePaternityRelation < ApplicationRecord

  belongs_to :task, optional: true
  belongs_to :parent, polymorphic: true, optional: true
  belongs_to :child, polymorphic: true, optional: true

  validates_presence_of :task, :parent, :child

  attr_accessible :task, :parent, :child

  class << self
    def parent_approval(task)
      find_by_task_id(task.id).parent
    end
  end

end
