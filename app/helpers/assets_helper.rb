module AssetsHelper

  def generate_assets_menu()
    [

      [ "#", "icon-menu-blog",       _('Blogs') ],
      [ "#", "icon-menu-album",      _('Albuns') ],
      [ "#", "icon-menu-product",    _('Products') ],
      [ "#", "icon-menu-enterprise", _('Enterprises') ],
      [ "#", "icon-menu-community",  _('Communities') ],

    ].map do |target,css_class,name|
      content_tag('li', link_to(content_tag('span', '', :class => css_class) + name, target))
    end.join("\n")
  end

end
