class SubOrganizationsPlugin::ApprovePaternityRelation < Noosfero::Plugin::ActiveRecord
  belongs_to :task
  belongs_to :parent, :polymorphic => true
  belongs_to :child, :polymorphic => true

  validates_presence_of :task, :parent, :child

  class << self
    def parent(task)
      find_by_task_id(task.id).parent
    end

    def pending_children(parent)
      options = {
        :select => "distinct profiles.*",
        :joins => "inner join sub_organizations_plugin_approve_paternity_relations as relations on profiles.id=relations.child_id inner join tasks on relations.task_id=tasks.id",
        :conditions => ["relations.parent_id = ? AND tasks.status = 1", parent.id]
      }
      ActiveRecord::NamedScope::Scope.new(Organization, options)
    end
  end

end
