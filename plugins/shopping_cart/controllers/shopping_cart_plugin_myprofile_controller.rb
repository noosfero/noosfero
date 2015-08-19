class ShoppingCartPluginMyprofileController < MyProfileController

  helper DeliveryPlugin::DisplayHelper

  def edit
    params[:settings] = treat_cart_options(params[:settings])
    @settings = profile.shopping_cart_settings params[:settings] || {}
    respond_to do |format|
      format.js do
        if request.post?
          @success = @settings.save!
        end
      end
      format.html
    end
  end

  protected

  def treat_cart_options(settings)
    return if settings.blank?
    settings[:enabled] = settings[:enabled] == '1'
    settings
  end

end
