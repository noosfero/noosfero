module BreadcrumbsPluginHelper

  def action(action)
    { :edit => c_('Edit'),
      :upload_files => _('Upload Files'),
      :new => c_('New'),
      :members => _('Members'),
      :events => _('Events')
    }[action.to_sym] || action
  end

  def page_trail(page)
    links = []
    page.ancestors.reverse.each do |p|
      links << { :name => p.title, :url => p.url }
    end
    links << { :name => page.title, :url => page.url }
    links
  end

  def trail(block, page, profile=nil, params={})
    links = []
    if page
      links += page_trail(page)
    elsif params[:controller] == 'cms' && (id = params[:id] || params[:parent_id])
      links += page_trail(Article.find(id))
      if block.show_cms_action
        links << { :name => action(params[:action]), :url => params }
      end
    elsif (params[:controller] == 'profile' || params[:controller] == 'events')
      _params = {:controller=> 'profile', :action =>'index', :profile => params[:profile]}
      links << { :name => _('Profile'), :url => _params }
      unless params[:action] == 'index'
        links << { :name => action(params[:action]), :url => params }
      end
    end
    if !links.empty? && profile && block.show_profile
      links.unshift({:name => profile.name, :url => profile.url})
    end
    links
  end

end
