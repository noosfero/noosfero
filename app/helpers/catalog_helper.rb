module CatalogHelper

  include DisplayHelper
  include ManageProductsHelper

  def breadcrumb(category)
    start = link_to(_('Start'), {:action => 'index'})
    ancestors = category.ancestors.map { |c| link_to(c.name, {:action => 'index', :level => c.id}) }.reverse
    current_level = content_tag('strong', category.name)
    all_items = [start] + ancestors + [current_level]
    content_tag('div', all_items.join(' &rarr; '), :id => 'breadcrumb')
  end

  def category_link(category, sub = false)
    count = profile.products.from_category(category).count
    name = truncate(category.name, :length => 22 - count.to_s.size)
    link_name = sub ? name : content_tag('strong', name)
    link = link_to(link_name, {:action => 'index', :level => category.id}, :title => category.name)
    content_tag('li', "#{link} (#{count})") if count > 0
  end

  def category_sub_links(category)
    sub_categories = []
    category.children.order(:name).each do |sub_category|
      sub_categories << category_link(sub_category, true)
    end
    content_tag('ul', sub_categories) if sub_categories.size > 1
  end

end
