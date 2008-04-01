module AssetsHelper

  def generate_assets_menu()
    [

      [ { :controller => 'search', :action => 'assets', :asset => 'articles' }, "icon-menu-articles",   _('Articles') ],
      [ { :controller => 'search', :action => 'assets', :asset => 'people' }, "icon-menu-people",     _('People') ],
      [ { :controller => 'search', :action => 'assets', :asset => 'products' }, "icon-menu-product",    _('Products') ],
      [ { :controller => 'search', :action => 'assets', :asset => 'enterprises' }, "icon-menu-enterprise", _('Enterprises') ],
      [ { :controller => 'search', :action => 'assets', :asset => 'communities' }, "icon-menu-community",  _('Communities') ],
      [ { :controller => 'search', :action => 'assets', :asset => 'comments'}, "icon-menu-comments",   _('Comments') ],

    ].map do |target,css_class,name|
      content_tag('li', link_to(content_tag('span', '', :class => css_class) + name, target))
    end.join("\n")
  end

end
