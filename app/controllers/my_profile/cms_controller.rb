class CmsController < MyProfileController
  
  define_option :page_class, Article
  
  protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  protected

  def profile
    Profile.find_by_identifier(params[:profile]) 
  end

  def user
    current_user.person
  end


end
