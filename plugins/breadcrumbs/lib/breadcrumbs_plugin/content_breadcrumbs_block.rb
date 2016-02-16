class BreadcrumbsPlugin::ContentBreadcrumbsBlock < Block

  settings_items :show_cms_action, :type => :boolean, :default => true
  settings_items :show_profile, :type => :boolean, :default => true
  settings_items :show_section_name, :type => :boolean, :default => true

  attr_accessible :show_cms_action, :show_profile, :show_section_name

  def self.description
    _("<p>Display a breadcrumb of the current content navigation.</p><p>You could choose if the breadcrumb is going to appear in the cms editing or not.</p> <p>There is either the option of display the profile location in the breadcrumb path.</p>")
  end

  def self.short_description
    _('Breadcrumb')
  end

  def self.pretty_name
    _('Breadcrumbs Block')
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
    elsif (params[:controller] == 'profile' || params[:controller] == 'events')
      links << { :name => _('Profile'), :url => {:controller=> 'profile', :action =>'index', :profile =>params[:profile]}}
      links << { :name => profile_action(params[:action]), :url => params } unless params[:action] == 'index'
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
        separator = content_tag('span', ' > ', :class => 'separator')

        breadcrumb = trail.map do |t|
          link_to(t[:name], t[:url], :class => 'item')
        end.join(separator)

        if block.show_section_name
          section_name = block.show_profile ? trail.second[:name] : trail.first[:name]
          breadcrumb << content_tag('div', section_name, :class => 'section-name')
        end

        breadcrumb
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
  PROFILE_ACTIONS = {:members => _('Members'), :events => _('Events')}

  def cms_action(action)
    CMS_ACTIONS[action.to_sym] || action
  end

  def profile_action(action)
    PROFILE_ACTIONS[action.to_sym] || action
  end

end
