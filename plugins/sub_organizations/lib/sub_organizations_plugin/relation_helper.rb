module SubOrganizationsPlugin::RelationHelper
  def display_relation(organization,type,display_mode)
    if display_mode == 'full'
      render :partial => 'sub_organizations_plugin_profile/full_related_organizations', :locals => {:organizations => organization,:organization_type => type}
    else
      render :partial => 'sub_organizations_plugin_profile/related_organizations', :locals => {:organizations => organization, :organization_type => type}
    end
  end
end