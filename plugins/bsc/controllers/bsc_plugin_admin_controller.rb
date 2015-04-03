class BscPluginAdminController < AdminController

  include BscPlugin::BscHelper

  def new
    @bsc = BscPlugin::Bsc.new(params[:profile_data])
    if request.post? && @bsc.valid?
      @bsc.user = current_user
      @bsc.save!
      @bsc.add_admin(user)
      session[:notice] = _('Your Bsc was created.')
      redirect_to :controller => 'profile_editor', :profile => @bsc.identifier
    end
  end

  def save_validations
    enterprises = [Enterprise.find(params[:q].split(','))].flatten

    begin
      enterprises.each { |enterprise| enterprise.validated = true ; enterprise.save! }
      session[:notice] = _('Enterprises validated.')
      redirect_to :controller => 'admin_panel'
    rescue Exception => ex
      session[:notice] = _('Enterprise validations couldn\'t be saved.')
      logger.info ex
      redirect_to :action => 'validate_enterprises'
    end
  end

  def search_enterprise
    render :text => Enterprise.not_validated.
      where("type <> 'BscPlugin::Bsc' AND (name LIKE ? OR identifier LIKE ?)", "%#{params[:q]}%", "%#{params[:q]}%").
      map{ |enterprise| {:id => enterprise.id, :name => enterprise.name} }.
      to_json
  end

end

