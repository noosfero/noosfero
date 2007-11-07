class CmsController < Comatose::AdminController
  include PermissionCheck
  
  
  
  define_option :page_class, Article
  
  protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  protected

  def profile
    Profile.find_by_identifier(params[:profile]) 
  end
end
