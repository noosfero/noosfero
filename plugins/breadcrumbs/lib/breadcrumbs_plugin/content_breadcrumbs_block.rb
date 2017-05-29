class BreadcrumbsPlugin::ContentBreadcrumbsBlock < Block

  settings_items :show_cms_action, :type => :boolean, :default => true
  settings_items :show_profile, :type => :boolean, :default => true
  settings_items :show_section_name, :type => :boolean, :default => true

  attr_accessible :show_cms_action, :show_profile, :show_section_name

  def self.description
    N_("<p>Display a breadcrumb of the current content navigation.</p><p>You could choose if the breadcrumb is going to appear in the cms editing or not.</p> <p>There is either the option of display the profile location in the breadcrumb path.</p>")
  end

  def self.short_description
    N_('Breadcrumb')
  end

  def self.pretty_name
    N_('Breadcrumbs Block')
  end

  def help
    N_('This block displays breadcrumb trail.')
  end

  def cacheable?
    false
  end

  def api_content(params = {})
    links = []
    params = HashWithIndifferentAccess.new(params)
    links << profile_link(params)
    links << page_links(params)
    { links: links.compact.flatten }
  end

  private

  def profile_link(params)
    return nil if (params || {})[:profile].blank?
    profile = environment.profiles.find_by(identifier: params[:profile])
    return nil if profile.blank?
    { :name => profile.name, :url => "/#{profile.identifier}" }
  end

  def page_links(params)
    return nil if (params || {})[:page].blank?
    page = owner.articles.find_by(path: params[:page])
    return nil if page.blank?
    page_trail(page)
  end

  def page_trail(page)
    links = page.ancestors.reverse.map { |p| { :name => p.title, :url => p.full_path } } || []
    links << { :name => page.title, :url => page.full_path }
  end
end
