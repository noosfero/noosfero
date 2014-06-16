require_dependency 'organization'
class Organization
  settings_items :sub_organizations_plugin_parent_to_be

  attr_accessible :sub_organizations_plugin_parent_to_be

  after_create do |organization|
    if organization.sub_organizations_plugin_parent_to_be.present?
      parent = Organization.find(organization.sub_organizations_plugin_parent_to_be)
      SubOrganizationsPlugin::Relation.add_children(parent,organization)
    end
  end

  FIELDS << 'sub_organizations_plugin_parent_to_be'

  scope :children, lambda { |parent|
    options = {
      :joins => "inner join sub_organizations_plugin_relations as relations on profiles.id=relations.child_id",
      :conditions => ["relations.parent_id = ?", parent.id]
    }
  }

  scope :parents, lambda { |*children|
    options = {
      :joins => "inner join sub_organizations_plugin_relations as relations on profiles.id=relations.parent_id",
      :conditions => ["relations.child_id in (?)", children.map(&:id)]
    }
  }

  scope :pending_children, lambda { |parent|
    options = {
      :select => "distinct profiles.*",
      :joins => "inner join sub_organizations_plugin_approve_paternity_relations as relations on profiles.id=relations.child_id inner join tasks on relations.task_id=tasks.id",
      :conditions => ["relations.parent_id = ? AND tasks.status = 1", parent.id]
    }
  }

end
