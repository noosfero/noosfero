class ProfileQuotasController < AdminController

  def index
    asset = params[:asset].in?(type_filters.values) ? params[:asset]
                                                    : :profiles
    order = params[:order_by].in?(order_filters.values) ? params[:order_by]
                                                        : nil
    scope = environment.send(asset).no_templates
    results = find_by_contents(asset, environment, scope, params[:q],
                               paginate_options, filter: order)[:results]
    @profiles = results.order('name')

    if request.xhr?
      respond_to do |format|
        format.js
        format.json { render json: @profiles.map(&:name) }
      end
    else
      @type_filters = type_filters
      @order_filters = order_filters
      @kinds = valid_classes.map do |klass|
        [ klass, environment.kinds.where(:type => klass.to_s) ]
      end.to_h
    end
  end

  def edit_class
    type = params['type'].try(:capitalize)
    begin
      raise NameError unless type.in?(valid_classes.map(&:to_s))
      @klass = type.constantize
      if request.post?
        environment.metadata['quotas'] ||= {}
        environment.metadata['quotas'][type] = params['quota']['size']
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

  def reset_class
    if request.delete?
      begin
        type = params['type'].try(:capitalize)
        raise NameError unless type.in?(valid_classes.map(&:to_s))

        quota = environment.metadata['quotas'].try(:[], type)
        profiles = environment.profiles.where(type: type)
        profiles.update_all(upload_quota: quota)
      rescue NameError
        session[:notice] = _('Invalid profile type')
      end
    end
    redirect_to action: :index
  end

  def reset_kind
    kind = environment.kinds.find_by(id: params[:id])
    if request.delete? && kind.present?
      quota = kind.upload_quota.nil? ? '' : kind.upload_quota
      kind.profiles.update_all(upload_quota: quota)
    end
    redirect_to action: :index
  end

  def reset_profile
    profile = environment.profiles.find_by(id: params[:id])
    if request.delete? && profile.present?
      profile.update_attributes(upload_quota: nil)
    end
    redirect_to action: :index
  end

  private

  def update_record(obj)
    if request.post?
      obj.upload_quota = params['quota']['size']
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

  def order_filters
    {
      _('Sort by name') => nil,
      _('Higher disk usage') => 'higher_disk_usage',
      _('Lower disk usage') => 'lower_disk_usage'
    }
  end

  def valid_classes
    [Person, Community, Enterprise]
  end

end
