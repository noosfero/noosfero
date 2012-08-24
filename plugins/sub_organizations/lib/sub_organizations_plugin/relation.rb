class SubOrganizationsPlugin::Relation < Noosfero::Plugin::ActiveRecord
  belongs_to :parent, :polymorphic => true
  belongs_to :child, :polymorphic => true

  validates_presence_of :parent, :child
  validate :no_self_reference
  validate :no_cyclical_reference, :if => 'parent.present? && child.present?'
  validate :no_multi_level, :if => 'parent.present? && child.present?'

  def no_self_reference
    errors.add(:child, _('self-reference is not allowed.')) if parent == child
  end

  def no_cyclical_reference
    if self.class.children(child).include?(parent)
      errors.add(:child, _('cyclical reference is not allowed.'))
    end
  end

  def no_multi_level
    if self.class.parents(parent).present? || self.class.children(child).present?
      errors.add(:child, _('multi-level paternity is not allowed.'))
    end
  end

  class << self
    def children(parent)
      options = {
        :select => "profiles.*",
        :joins => "inner join sub_organizations_plugin_relations as relations on profiles.id=relations.child_id",
        :conditions => ["relations.parent_id = ?", parent.id]
      }
      ActiveRecord::NamedScope::Scope.new(Organization, options)
    end

    def parents(child)
      options = {
        :select => "profiles.*",
        :joins => "inner join sub_organizations_plugin_relations as relations on profiles.id=relations.parent_id",
        :conditions => ["relations.child_id = ?", child.id]
      }
      ActiveRecord::NamedScope::Scope.new(Organization, options)
    end

    def add_children(parent, *children)
      children.each {|child| create!(:parent => parent, :child => child)}
    end

    def remove_children(parent, *children)
      children.flatten.each {|child| find_by_parent_id_and_child_id(parent.id, child.id).destroy}
    end
  end

end
