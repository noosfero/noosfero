require_dependency 'organization'
class Organization
  settings_items :sub_organizations_plugin_parent_to_be

  after_create do |organization|
    if organization.sub_organizations_plugin_parent_to_be.present?
      parent = Organization.find(organization.sub_organizations_plugin_parent_to_be)
      SubOrganizationsPlugin::Relation.add_children(parent,organization)
    end
  end

  FIELDS << 'sub_organizations_plugin_parent_to_be'
end
