class EnterpriseHomepage < Article

  def self.type_name
    _('Homepage')
  end

  def self.short_description
    __('Enterprise homepage')
  end

  def self.description
    _('Display the summary of profile.')
  end

  def name
    profile.nil? ? _('Homepage') : profile.name
  end

  def to_html(options = {})
    enterprise_homepage = self
    lambda do
      extend EnterpriseHomepageHelper
      @products = profile.products.paginate(:order => 'id asc', :per_page => 9, :page => 1)
      render :partial => 'content_viewer/enterprise_homepage', :object => enterprise_homepage
    end
  end

  def can_display_hits?
    false
  end

end
