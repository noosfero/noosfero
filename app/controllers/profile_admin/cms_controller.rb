class CmsController < Comatose::AdminController
  extend PermissionCheck
  
  needs_profile
  
  define_option :page_class, Article
  
  protect [:edit, :new, :reorder, :delete], 'post_content', :profile

  protected

  def profile
    Profile.find_by_identifier(params[:profile]) 
  end
end
