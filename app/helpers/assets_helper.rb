module AssetsHelper

  def generate_assets_menu()

    options = { :controller => 'search', :action => 'assets', :category_path => (@category ? @category.explode_path : []) }
    [
      [ options.merge(:asset => 'articles'), "icon-menu-articles",   _('Articles') ],
      [ options.merge(:asset => 'people'), "icon-menu-people",     _('People') ],
      [ options.merge(:asset => 'products'), "icon-menu-product",    _('Products') ],
      [ options.merge(:asset => 'enterprises'), "icon-menu-enterprise", _('Enterprises') ],
      [ options.merge(:asset => 'communities'), "icon-menu-community",  _('Communities') ],
      [ options.merge(:asset => 'events'), "icon-event",   _('Events') ],

    ].select do |target, css_class, name|
      !environment.enabled?('disable_asset_' + target[:asset])
    end.map do |target,css_class,name|
      content_tag('li',
                  link_to(
                    content_tag('span', '', :class => css_class) +
                    content_tag('strong', name),
                    target ), :class => "asset_#{target[:asset]}")
    end.join("\n")
  end

end
