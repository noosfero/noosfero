class CirclesController < MyProfileController

  before_action :accept_only_post, :only => [:create, :update, :destroy]

  def index
    @circles = profile.circles
  end

  def new
    @circle = Circle.new
  end

  def create
    @circle = Circle.new(params[:circle].merge({ :person => profile }))
    if @circle.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def xhr_create
    if request.xhr?
      circle = Circle.new(params[:circle].merge({:person => profile }))
      if circle.save
        render :partial => "circle_checkbox", :locals => { :circle => circle },
               :status => 201
      else
        render :text => _('The circle could not be saved'), :status => 400
      end
    else
      render_not_found
    end
  end

  def edit
    @circle = Circle.find_by_id(params[:id])
    render_not_found if @circle.nil?
  end

  def update
    @circle = Circle.find_by_id(params[:id])
    return render_not_found if @circle.nil?

    if @circle.update(params[:circle])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @circle = Circle.find_by_id(params[:id])
    return render_not_found if @circle.nil?
    @circle.destroy
    redirect_to :action => 'index'
  end
end
