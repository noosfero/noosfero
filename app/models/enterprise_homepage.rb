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
  def to_html
    display_profile_info(self.profile) + content_tag('div', self.body || '')
  end

end
