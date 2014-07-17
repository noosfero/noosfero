module CatalogHelper

  include DisplayHelper
  include ManageProductsHelper

  def catalog_load_index options = {:page => params[:page], :show_categories => true}
    if options[:show_categories]
      @category = params[:level] ? ProductCategory.find(params[:level]) : nil
      @categories = ProductCategory.on_level(params[:level]).order(:name)
    end

    @products = profile.products.from_category(@category).
      reorder('available desc, highlighted desc, name asc').
      paginate(:per_page => @profile.products_per_catalog_page, :page => options[:page])
  end

  def breadcrumb(category)
    start = link_to(_('Start'), {:controller => :catalog, :action => 'index'})
    ancestors = category.ancestors.map { |c| link_to(c.name, {:controller => :catalog, :action => 'index', :level => c.id}) }.reverse
    current_level = content_tag('strong', category.name)
    all_items = [start] + ancestors + [current_level]
    content_tag('div', all_items.join(' &rarr; '), :id => 'breadcrumb')
  end

  def category_link(category)
    count = profile.products.from_category(category).count
    name = truncate(category.name, :length => 22 - count.to_s.size)
    link = link_to(name, {:controller => 'catalog', :action => 'index', :level => category.id}, :title => category.name)
    content_tag('div', "#{link} <span class=\"count\">#{count}</span>") if count > 0
  end

  def category_with_sub_list(category)
    content_tag 'li', "#{category_link(category)}\n#{sub_category_list(category)}"
  end

  def sub_category_list(category)
    sub_categories = []
    category.children.order(:name).each do |sub_category|
      cat_link = category_link sub_category
      sub_categories << content_tag('li', cat_link) unless cat_link.nil?
    end
    content_tag('ul', sub_categories.join) if sub_categories.size > 0
  end

end
