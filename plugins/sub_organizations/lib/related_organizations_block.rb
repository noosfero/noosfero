class RelatedOrganizationsBlock < ProfileListBlock
  settings_items :organization_type, type: :string, default: "both"

  attr_accessible :organization_type

  def self.description
    _("Related Organizations")
  end

  def display_type
    @display_type ||= { title: "related", action: "children" }
  end

  def default_title
    case organization_type
    when "enterprise"
      n_("{#} #{display_type[:title]} enterprise", "{#} #{display_type[:title]} enterprises", profile_count)
    when "community"
      n_("{#} #{display_type[:title]} community", "{#} #{display_type[:title]} communities", profile_count)
    else
      n_("{#} #{display_type[:title]} organization", "{#} #{display_type[:title]} organizations", profile_count)
    end
  end

  def help
    _("This block displays %s organizations of this organization") % display_type[:title]
  end

  def base_profiles
    organizations = related_organizations
    case organization_type
    when "enterprise"
      organizations.enterprises
    when "community"
      organizations.communities
    else
      organizations
    end
  end

  def related_organizations
    profile = self.owner
    organizations = Organization.parentz(profile)

    if organizations.blank?
      @display_type = { title: "sub", action: "children" }
      organizations = Organization.children(profile)
    else
      @display_type = { title: "parent", action: "parents" }
      organizations
    end
  end
end
