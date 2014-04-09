module API
  module APIHelpers
    PRIVATE_TOKEN_PARAM = :private_token

    def current_user
      private_token = params[PRIVATE_TOKEN_PARAM].to_s
      @current_user ||= User.find_by_private_token(private_token)
      @current_user = nil if !@current_user.nil? && @current_user.private_token_expired?
      @current_user
    end

    def current_person
      current_user.person unless current_user.nil?
    end

    def logout
      @current_user = nil
    end

    def environment
      @environment
    end

    def limit
      limit = params[:limit].to_i
      limit = default_limit if limit <= 0
      limit
    end

    def period(from_date, until_date)
      if from_date.nil?
        begin_period = Time.at(0).to_datetime
        end_period = until_date.nil? ? DateTime.now : until_date
      else
        begin_period = from_date
        end_period = DateTime.now
      end

      begin_period...end_period
    end

    def parse_content_type(content_type)
      return nil if content_type.blank?
      content_type.split(',').map do |content_type|
        content_type.camelcase
      end
    end

#FIXME see if its needed
#    def paginate(relation)
#      per_page  = params[:per_page].to_i
#      paginated = relation.page(params[:page]).per(per_page)
#      add_pagination_headers(paginated, per_page)
#
#      paginated
#    end

    def authenticate!
      unauthorized! unless current_user
    end

#FIXME see if its needed
#    def authenticated_as_admin!
#      forbidden! unless current_user.is_admin?
#    end
#
#FIXME see if its needed
#    def authorize! action, subject
#      unless abilities.allowed?(current_user, action, subject)
#        forbidden!
#      end
#    end
#
#FIXME see if its needed
#    def can?(object, action, subject)
#      abilities.allowed?(object, action, subject)
#    end

    # Checks the occurrences of required attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (required) - A hash consisting of keys that must be present
    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) unless params[key].present?
      end
    end

    # Checks the occurrences of uniqueness of attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (unique) - A hash consisting of keys that must be unique
    def unique_attributes!(obj, keys)
      keys.each do |key|
        cant_be_saved_request!(key) if obj.send("find_by_#{key.to_s}", params[key])
      end
    end

    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if params[key].present? or (params.has_key?(key) and params[key] == false)
      end
      attrs
    end

    # error helpers
    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end

    def cant_be_saved_request!(attribute)
      message = _("(Invalid request) #{attribute} can't be saved")
      render_api_error!(message, 400)
    end

    def bad_request!(attribute)
      message = _("(Bad request) #{attribute} not given")
      render_api_error!(message, 400)
    end

    def something_wrong!
      message = _("Something wrong happened")
      render_api_error!(message, 400)
    end

    def unauthorized!
      render_api_error!(_('Unauthorized'), 401)
    end

    def not_allowed!
      render_api_error!(_('Method Not Allowed'), 405)
    end

    def render_api_error!(message, status)
      error!({'message' => message, :code => status}, status)
    end

    protected

    def detect_stuff_by_domain
      @domain = Domain.find_by_name(request.host)
      if @domain.nil?
        @environment = Environment.default
        if @environment.nil? && Rails.env.development?
          # This should only happen in development ...
          @environment = Environment.create!(:name => "Noosfero", :is_default => true)
        end
      else
        @environment = @domain.environment
      end
    end

    private

    def default_limit 
      20
    end


  end
end
