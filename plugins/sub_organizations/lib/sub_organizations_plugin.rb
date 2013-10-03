class SubOrganizationsPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Sub-groups")
  end

  def self.plugin_description
    _("Adds the ability for groups to have sub-groups.")
  end

  def control_panel_buttons
    if context.profile.organization? && SubOrganizationsPlugin::Relation.parents(context.profile).blank?
      { :title => _('Manage sub-groups'), :icon => 'groups', :url => {:controller => 'sub_organizations_plugin_myprofile'} }
    end
  end

  def stylesheet?
    true
  end

  def organization_members(organization)
    children = SubOrganizationsPlugin::Relation.children(organization)
    Person.members_of(children) if children.present?
  end

  def has_permission?(person, permission, target)
    if !target.kind_of?(Environment) && target.organization?
      SubOrganizationsPlugin::Relation.parents(target).map do |parent|
        person.has_permission_without_plugins?(permission, parent)
      end.include?(true)
    end
  end

  def new_community_hidden_fields
    parent_to_be = context.params[:sub_organizations_plugin_parent_to_be]
    {'sub_organizations_plugin_parent_to_be' => parent_to_be} if parent_to_be.present?
  end

  def enterprise_registration_hidden_fields
    parent_to_be = context.params[:sub_organizations_plugin_parent_to_be]
    {'sub_organizations_plugin_parent_to_be' => parent_to_be} if parent_to_be.present?
  end
end
