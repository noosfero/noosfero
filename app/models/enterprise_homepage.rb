class EnterpriseHomepage < Article

  def self.type_name
    _('Homepage')
  end

  def self.short_description
    _('Enterprise homepage')
  end

  def self.description
    _('Display the summary of profile.')
  end

  def name
    profile.nil? ? _('Homepage') : profile.name
  end

  def to_html(options = {})
    enterprise_homepage = self
    proc do
      extend EnterpriseHomepageHelper
      extend CatalogHelper
      catalog_load_index :page => 1, :show_categories => false
      render :partial => 'content_viewer/enterprise_homepage', :object => enterprise_homepage
    end
  end

  # disable cache because of products
  def cache_key params = {}, the_profile = nil, language = 'en'
    rand
  end

  def can_display_hits?
    false
  end

end
