class MetadataPlugin::Controllers

  def manage_products
    :@product
  end

  def content_viewer
    lambda do
      if profile and @page and profile.home_page_id == @page.id
        @profile
      elsif @page.respond_to? :encapsulated_file
        @page.encapsulated_file
      else
        @page
      end
    end
  end

  def profile
    :@profile
  end

  def home
    :@environment
  end

end
