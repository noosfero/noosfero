class SubOrganizationsPluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  before_filter :organizations_only

  def children
    @organizations = SubOrganizationsPlugin::Relation.children(profile)

    render 'related_organizations'
  end

  def parents
    @organizations = SubOrganizationsPlugin::Relation.parents(profile)

    render 'related_organizations'
  end


  private

  def organizations_only
    render_not_found if !profile.organization?
  end

end
