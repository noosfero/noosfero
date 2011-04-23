class ShoppingCartPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def edit
    if request.post?
      begin
        profile.shopping_cart = params[:shopping_cart] == '1' ? true : false
        profile.save!
        session[:notice] = _('Option updated successfully.')
      rescue Exception => exception
        session[:notice] = _('Option wasn\'t updated successfully.')
      end
      redirect_to :action => 'edit'
    end
  end

end
