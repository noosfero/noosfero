class BreadcrumbsBlock < Block

  settings_items :show_cms_action, :type => :boolean, :default => true
  settings_items :show_profile, :type => :boolean, :default => true

  def self.description
    _('Breadcrumbs')
  end

  def help
    _('This block displays breadcrumb trail.')
  end

  def trail(page, params={})
    links = []
    if page
      links = page.ancestors.reverse.map { |p| { :name => p.title, :url => p.url } }
      links << { :name => page.title, :url => page.url }
    elsif params[:controller] == 'cms'
      id = params[:id] || params[:parent_id]
      links = trail(Article.find(id)) if id
      links << { :name => params[:action], :url => params } if show_cms_action
    end
    links
  end

  def content(args={})
    block = self
    lambda do
      trail = block.trail(@page, params)
      if !trail.empty?
        trail = [ {:name => @profile.name, :url => @profile.url} ] + trail if block.show_profile
        trail.map { |t| link_to(t[:name], t[:url], :class => 'item') }.join(content_tag('span', ' > ', :class => 'separator')) 
      else
        ''
      end
    end
  end

end
