class BreadcrumbsPlugin < Noosfero::Plugin

  def self.plugin_name
    "BreadcrumbsPlugin"
  end

  def self.plugin_description
    _("A plugin that add a block to display breadcrumbs.")
  end

  def self.extra_blocks
    { BreadcrumbsPlugin::ContentBreadcrumbsBlock => {:type => [Community, Person, Enterprise] } }
  end

  def stylesheet?
    true
  end

end
