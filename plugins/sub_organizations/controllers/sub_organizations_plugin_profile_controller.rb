class SubOrganizationsPluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  before_filter :organizations_only

  def children
    children = Organization.children(profile)
    family_relation(children)
    render 'related_organizations'
  end

  def parents
    parents = Organization.parents(profile)
    family_relation(parents)
    render 'related_organizations'
  end

  private

  def family_relation(_profile)
    @communities = _profile.communities
    @enterprises = _profile.enterprises
    @full = true

    if !params[:type] and !params[:display]
      @communities = SubOrganizationsPlugin.limit(@communities)
      @enterprises = SubOrganizationsPlugin.limit(@enterprises)
      @full = false
    elsif !params[:type]
      @total = _profile
      @total = @total.paginate(:per_page => 12, :page => params[:npage])
      if params[:display] == 'compact'
        @full = false
      end
    else
      @communities = @communities.paginate(:per_page => 12, :page => params[:npage])
      @enterprises = @enterprises.paginate(:per_page => 12, :page => params[:npage])
    end
  end

  def organizations_only
    render_not_found if !profile.organization?
  end

end
