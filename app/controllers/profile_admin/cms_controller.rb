class CmsController < ComatoseAdminController
  extend PermissionCheck
  
  define_option :page_class, Article

  # not yet
  # protect [:edit, :new, :reorder, :delete], :post_content, :profile

  protected
  def profile
    Profile.find_by_identifier(params[:profile])
  end
end
