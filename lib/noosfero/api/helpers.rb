module Noosfero
  module API
    module APIHelpers
      PRIVATE_TOKEN_PARAM = :private_token
      ALLOWED_PARAMETERS = [:parent_id, :from, :until, :content_type] 

      def current_user
        private_token = (params[PRIVATE_TOKEN_PARAM] || headers['Private-Token']).to_s
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
        return nil if from_date.nil? && until_date.nil?
  
        begin_period = from_date.nil? ? Time.at(0).to_datetime : from_date
        end_period = until_date.nil? ? DateTime.now : until_date
  
        begin_period..end_period
      end
  
      def parse_content_type(content_type)
        return nil if content_type.blank?
        content_type.split(',').map do |content_type|
          content_type.camelcase
        end
      end
  
      def find_article(articles, id)
        article = articles.find(id)
        article.display_to?(current_user.person) ? article : forbidden!
      end

      def make_conditions_with_parameter(params = {})
        parsed_params = parser_params(params)
        conditions = {}
        from_date = DateTime.parse(parsed_params.delete(:from)) if parsed_params[:from]
        until_date = DateTime.parse(parsed_params.delete(:until)) if parsed_params[:until]
  
        conditions[:type] = parse_content_type(parsed_params.delete(:content_type)) unless parsed_params[:content_type].nil?
  
        conditions[:created_at] = period(from_date, until_date) if from_date || until_date
        conditions.merge!(parsed_params)
  
        conditions
      end

      def make_order_with_parameters(params)
        params[:order] || "created_at DESC"
      end

      def select_filtered_collection_of(object, method, params)
        conditions = make_conditions_with_parameter(params)
        order = make_order_with_parameters(params)

        if params[:reference_id]
          objects = object.send(method).send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).where(conditions).limit(limit).order(order)
        else
          objects = object.send(method).where(conditions).limit(limit).order(order)
        end
        objects
      end
  
      def authenticate!
        unauthorized! unless current_user
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
      
      ##########################################
      #              error helpers             #
      ##########################################
  
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
  
      def render_api_errors!(messages)
        render_api_error!(messages.join(','), 400)
      end
      protected

      def set_session_cookie
        cookies['_noosfero_api_session'] = { value: @current_user.private_token, httponly: true } if @current_user.present?
      end

      def setup_multitenancy
        Noosfero::MultiTenancy.setup!(request.host)
      end
  
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

      def parser_params(params) 
        parsed_params = {}
        params.map do |k,v| 
          parsed_params[k.to_sym] = v if ALLOWED_PARAMETERS.include?(k.to_sym)
        end
        parsed_params 
      end
  
      def default_limit
        20
      end
  
      def parse_content_type(content_type)
        return nil if content_type.blank?
        content_type.split(',').map do |content_type|
          content_type.camelcase
        end
      end
  
      def period(from_date, until_date)
        begin_period = from_date.nil? ? Time.at(0).to_datetime : from_date
        end_period = until_date.nil? ? DateTime.now : until_date
  
        begin_period..end_period
      end
  
    end
  end
end
