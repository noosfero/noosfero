module API
  module APIHelpers
    PRIVATE_TOKEN_PARAM = :private_token

    def current_user
      private_token = params[PRIVATE_TOKEN_PARAM].to_s
      @current_user ||= User.find_by_private_token(private_token)
      @current_user = nil if !@current_user.nil? && @current_user.private_token_expired?
      @current_user
    end

    def logout
      @current_user = nil
    end


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

#    def authenticated_as_admin!
#      forbidden! unless current_user.is_admin?
#    end
#
#    def authorize! action, subject
#      unless abilities.allowed?(current_user, action, subject)
#        forbidden!
#      end
#    end
#
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

    def bad_request!(attribute)
      message = ["400 (Bad request)"]
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end

    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def not_allowed!
      render_api_error!('Method Not Allowed', 405)
    end

    def render_api_error!(message, status)
      error!({'message' => message}, status)
    end

#    private
#
#    def add_pagination_headers(paginated, per_page)
#      request_url = request.url.split('?').first
#
#      links = []
#      links << %(<#{request_url}?page=#{paginated.current_page - 1}&per_page=#{per_page}>; rel="prev") unless paginated.first_page?
#      links << %(<#{request_url}?page=#{paginated.current_page + 1}&per_page=#{per_page}>; rel="next") unless paginated.last_page?
#      links << %(<#{request_url}?page=1&per_page=#{per_page}>; rel="first")
#      links << %(<#{request_url}?page=#{paginated.total_pages}&per_page=#{per_page}>; rel="last")
#
#      header 'Link', links.join(', ')
#    end

  end
end
