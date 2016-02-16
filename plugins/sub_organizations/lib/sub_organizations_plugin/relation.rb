class SubOrganizationsPlugin::Relation < ActiveRecord::Base

  belongs_to :parent, :polymorphic => true
  belongs_to :child, :polymorphic => true

  validates_presence_of :parent, :child
  validate :no_self_reference
  validate :no_cyclical_reference, :if => 'parent.present? && child.present?'
  validate :no_multi_level, :if => 'parent.present? && child.present?'

  attr_accessible :parent, :child

  def no_self_reference
    errors.add(:child, c_('self-reference is not allowed.')) if parent == child
  end

  def no_cyclical_reference
    if Organization.children(child).include?(parent)
      errors.add(:child, c_('cyclical reference is not allowed.'))
    end
  end

  def no_multi_level
    if Organization.parents(parent).present? || Organization.children(child).present?
      errors.add(:child, _('multi-level paternity is not allowed.'))
    end
  end

  class << self
    def add_children(parent, *children)
      children.each {|child| create!(:parent => parent, :child => child)}
    end

    def remove_children(parent, *children)
      children.flatten.each {|child| find_by_parent_id_and_child_id(parent.id, child.id).destroy}
    end
  end

end
