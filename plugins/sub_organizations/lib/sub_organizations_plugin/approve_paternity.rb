class SubOrganizationsPlugin::ApprovePaternity < Task
  validates_presence_of :requestor, :target

  settings_items :temp_parent_id
  settings_items :temp_parent_type

  after_create do |task|
    r = SubOrganizationsPlugin::ApprovePaternityRelation.create!(:task => task, :parent => task.temp_parent, :child => task.target)
  end

  def temp_parent
    temp_parent_type.constantize.find(temp_parent_id)
  end

  def parent
    SubOrganizationsPlugin::ApprovePaternityRelation.parent_approval(self)
  end

  def title
    _("Paternity request")
  end

  def linked_subject
    {:text => parent.name, :url => parent.url}
  end

  def information
    {:message => _('%{requestor} wants to add this organization as a sub-organization of %{linked_subject}.')}
  end

  def reject_details
    true
  end

  def icon
    {:type => :profile_image, :profile => parent, :url => parent.url}
  end

  def task_created_message
    ('%{requestor} wants to add your organization %{target} as a sub-organization of %{parent}.') % {:requestor => requestor.name, :target => target.name, :parent => temp_parent.name}
  end

  def task_finished_message
    ('%{target} accepted your request to add it as a sub-organization of %{parent}.') % {:target => target.name, :parent => parent.name}
  end

  def task_cancelled_message
    ('%{target} refused your request to add it as a sub-organization of %{parent}.') % {:target => target.name, :parent => parent.name}
  end

  protected

  def perform
    SubOrganizationsPlugin::Relation.add_children(parent, target)
  end

end
