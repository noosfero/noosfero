class EnterpriseHomepage < Article

  def self.short_description
    _('Enterprise homepage.')
  end

  def self.description
    _('Display the summary of profile.')
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include EnterpriseHomepageHelper
  include CatalogHelper

  def to_html
    products = self.profile.products
    display_profile_info(self.profile) + content_tag('div', self.body || '') +
    (self.profile.environment.enabled?('disable_products_for_enterprises') ? '' : display_products_list(self.profile, products))
  end

end
