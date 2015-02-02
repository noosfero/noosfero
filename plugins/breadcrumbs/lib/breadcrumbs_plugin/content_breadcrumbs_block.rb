class BreadcrumbsPlugin::ContentBreadcrumbsBlock < Block

  settings_items :show_cms_action, :type => :boolean, :default => true
  settings_items :show_profile, :type => :boolean, :default => true

  attr_accessible :show_cms_action, :show_profile

  def self.description
    _('Content Breadcrumbs')
  end

  def help
    _('This block displays breadcrumb trail.')
  end

  def page_trail(page, params={})
    links = []
    if page
      links = page.ancestors.reverse.map { |p| { :name => p.title, :url => p.url } }
      links << { :name => page.title, :url => page.url }
    elsif params[:controller] == 'cms'
      id = params[:id] || params[:parent_id]
      links = page_trail(Article.find(id)) if id
      links << { :name => cms_action(params[:action]), :url => params } if show_cms_action
    end
    links
  end

  def trail(page, profile=nil, params={})
    links = page_trail(page, params)
    if profile && !links.empty? && show_profile
      [ {:name => profile.name, :url => profile.url} ] + links
    else
      links
    end
  end

  def content(args={})
    block = self
    proc do
      trail = block.trail(@page, @profile, params)
      if !trail.empty?
        trail.map { |t| link_to(t[:name], t[:url], :class => 'item') }.join(content_tag('span', ' > ', :class => 'separator'))
      else
        ''
      end
    end
  end

  def cacheable?
    false
  end

  protected

  CMS_ACTIONS = {:edit => c_('Edit'), :upload_files => _('Upload Files'), :new => c_('New')}

  def cms_action(action)
    CMS_ACTIONS[action.to_sym] || action
  end

end
