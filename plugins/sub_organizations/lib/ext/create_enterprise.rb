require_dependency 'create_enterprise'

class CreateEnterprise
  settings_items :sub_organizations_plugin_parent_to_be
  DATA_FIELDS << 'sub_organizations_plugin_parent_to_be'
end
