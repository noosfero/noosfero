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

end
