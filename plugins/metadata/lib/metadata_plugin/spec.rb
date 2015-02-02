
class MetadataPlugin::Spec

  Controllers = {
    manage_products: {
      variable: :@product,
    },
    content_viewer: {
      variable: proc do
        if profile and profile.home_page_id == @page.id
          @profile
        elsif @page.respond_to? :encapsulated_file
          @page.encapsulated_file
        else
          @page
        end
      end,
    },
    # fallback
    profile: {
      variable: :@profile,
    },
    # last fallback
    environment: {
      variable: :@environment,
    },
  }

end
