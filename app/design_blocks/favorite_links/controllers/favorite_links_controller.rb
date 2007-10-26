class FavoriteLinksController < ApplicationController


  # The methods above are specific for noosfero application. I think 
  # this it not the correct way to get this method. 
  #
  # We can create a method in the app/controllers/profile_admin folder
  # the inherit this method and adds only the two lines above.
  #
  # With this way we can reuse this block on many others case and each case
  # we follow the same way.
  # 
  # Specific for app
  needs_profile
  design :holder => 'profile'
  # End specific for app


  acts_as_design_block

  CONTROL_ACTION_OPTIONS = {
    'manage_links' => _('Manage Links'),
    'edit' => _('Edit'),
  }

  def index
    get_favorite_links
    design_render
  end

  def edit
    design_render_on_edit
  end

  def save
    if @design_block.update_attributes(params[:design_block])
      get_favorite_links
      design_render_on_edit :action => 'manage_links'
    else
      design_render_on_edit :nothing => true
    end
  end

  def manage_links
    get_favorite_links
    design_render_on_edit
  end

  def add_link
    design_render_on_edit
  end

  def remove_link
    @design_block.delete_link(params[:link])
    get_favorite_links
    design_render_on_edit :action => 'manage_links'
  end

  def get_favorite_links
    favorite_links = @design_block.favorite_links
    @favorite_links_pages, @favorite_links = paginate_by_collection favorite_links
  end

  def paginate_by_collection(collection, options = {})
    page = ( 1).to_i
    items_per_page = @design_block.limit_number
    offset = (page - 1) * items_per_page
    link_pages = Paginator.new(self, collection.size, items_per_page, page)
    collection = collection[offset..(offset + items_per_page - 1)]
    return link_pages, collection
  end

end
