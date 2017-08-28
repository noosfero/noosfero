class ProfileQuotasController < AdminController

  def index
    asset = params[:asset].in?(type_filters.values) ? params[:asset] : :profiles
    scope = environment.send(asset).no_templates.order('name')
    @profiles = find_by_contents(asset, environment, scope, params[:q],
                                 paginate_options)[:results]

    if request.xhr?
      respond_to do |format|
        format.js
        format.json { render json: @profiles.map(&:name) }
      end
    else
      @filters = type_filters
      @kinds = valid_classes.map do |klass|
        [ klass, environment.kinds.where(:type => klass.to_s) ]
      end.to_h
    end
  end

  def edit_class
    type = (params['type'] || '').capitalize
    begin
      valid_types = valid_classes.map(&:to_s).push('Profile')
      raise NameError unless type.in? valid_types
      @klass = type.constantize
      if request.post?
        environment.metadata['quotas'] ||= {}
        environment.metadata['quotas'][@klass.to_s] = params['quota']['size']
        if environment.save
          redirect_to action: :index
        end
      end
    rescue NameError
      session[:notice] = _('Invalid profile type')
      redirect_to action: :index
    end
  end

  def edit_kind
    @kind = environment.kinds.find(params[:id])
    update_record(@kind)
  end

  def edit_profile
    @profile = environment.profiles.find(params[:id])
    update_record(@profile)
  end

  private

  def update_record(obj)
    if request.post?
      obj.metadata['quota'] = params['quota']['size']
      if obj.save
        redirect_to action: :index
      end
    end
  end

  def paginate_options
    { :per_page => 10, :page => params[:npage] }
  end

  def type_filters
    {
      _('All profiles') => 'profiles',
      _('People') => 'people',
      _('Communities') => 'communities',
      _('Enterprises') => 'enterprises'
    }
  end

  def valid_classes
    [Person, Community, Enterprise]
  end

end
