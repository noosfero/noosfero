class CustomRoutesPluginAdminController < AdminController

  before_filter :accept_only_post, :only => [:create, :update, :destroy]

  def index
    @routes = environment.custom_routes.all
  end

  def new
    @route = environment.custom_routes.new
  end

  def create
    params[:route][:enabled] ||= false
    @route = environment.custom_routes.new(params[:route])

    if @route.save
      redirect_to action: :index
    else
      session[:notice] = _('Could not save the route mapping.')
      render action: :new
    end
  end

  def edit
    @route = environment.custom_routes.find_by(id: params[:route_id])
    render_not_found unless @route
  end

  def update
    params[:route][:enabled] ||= false
    @route = environment.custom_routes.find_by(id: params[:route_id])
    return render_not_found unless @route

    if @route.update(params[:route])
      redirect_to action: :index
    else
      session[:notice] = _('Could not update the route mapping.')
      render action: :edit
    end
  end

  def destroy
    begin
      environment.custom_routes.destroy(params[:route_id])
      render :json => { msg: 'ok' }, status: 200
    rescue
      render :json => { msg: 'Could not remove this route mapping' },
             status: 400
    end
  end

end
