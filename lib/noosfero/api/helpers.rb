require 'grape'
require_relative '../../find_by_contents'

  module Noosfero;
    module API
      module APIHelpers
      PRIVATE_TOKEN_PARAM = :private_token
      DEFAULT_ALLOWED_PARAMETERS = [:parent_id, :from, :until, :content_type, :author_id, :identifier]

      include SanitizeParams
      include Noosfero::Plugin::HotSpot
      include ForgotPasswordHelper
      include SearchTermHelper

      def set_locale
        I18n.locale = (params[:lang] || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
      end

      def init_noosfero_plugins
        plugins
      end

      def current_user
        private_token = (params[PRIVATE_TOKEN_PARAM] || headers['Private-Token']).to_s
        @current_user ||= User.find_by private_token: private_token
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

      def present_partial(model, options)
        if(params[:fields].present?)
          begin
            fields = JSON.parse(params[:fields])
            if fields.present?
              options.merge!(fields.symbolize_keys.slice(:only, :except))
            end
          rescue
            fields = params[:fields]
            fields = fields.split(',') if fields.kind_of?(String)
            options[:only] = Array.wrap(fields)
          end
        end
        present model, options
      end

      include FindByContents

      ####################################################################
      #### SEARCH
      ####################################################################
      def multiple_search?(searches=nil)
        ['index', 'category_index'].include?(params[:action]) || (searches && searches.size > 1)
      end
      ####################################################################

      def logger
        logger = Logger.new(File.join(Rails.root, 'log', "#{ENV['RAILS_ENV'] || 'production'}_api.log"))
        logger.formatter = GrapeLogging::Formatters::Default.new
        logger
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

      ARTICLE_TYPES = ['Article'] + Article.descendants.map{|a| a.to_s}
      TASK_TYPES = ['Task'] + Task.descendants.map{|a| a.to_s}

      def find_article(articles, id)
        article = articles.find(id)
        article.display_to?(current_person) ? article : forbidden!
      end

      def post_article(asset, params)
        return forbidden! unless current_person.can_post_content?(asset)

        klass_type= params[:content_type].nil? ? TinyMceArticle.name : params[:content_type]
        return forbidden! unless ARTICLE_TYPES.include?(klass_type)

        article = klass_type.constantize.new(params[:article])
        article.last_changed_by = current_person
        article.created_by= current_person
        article.profile = asset

        if !article.save
          render_api_errors!(article.errors.full_messages)
        end
        present_partial article, :with => Entities::Article
      end

      def present_article(asset)
        article = find_article(asset.articles, params[:id])
        present_partial article, :with => Entities::Article
      end

      def present_articles_for_asset(asset, method = 'articles')
        articles = find_articles(asset, method)
        present_articles(articles)
      end

      def present_articles(articles)
        present_partial paginate(articles), :with => Entities::Article
      end

      def find_articles(asset, method = 'articles')
        articles = select_filtered_collection_of(asset, method, params)
        if current_person.present?
          articles = articles.display_filter(current_person, nil)
        else
          articles = articles.published
        end
        articles
      end

      def find_task(asset, id)
        task = asset.tasks.find(id)
        current_person.has_permission?(task.permission, asset) ? task : forbidden!
      end

      def post_task(asset, params)
        klass_type= params[:content_type].nil? ? 'Task' : params[:content_type]
        return forbidden! unless TASK_TYPES.include?(klass_type)

        task = klass_type.constantize.new(params[:task])
        task.requestor_id = current_person.id
        task.target_id = asset.id
        task.target_type = 'Profile'

        if !task.save
          render_api_errors!(task.errors.full_messages)
        end
        present_partial task, :with => Entities::Task
      end

      def present_task(asset)
        task = find_task(asset, params[:id])
        present_partial task, :with => Entities::Task
      end

      def present_tasks(asset)
        tasks = select_filtered_collection_of(asset, 'tasks', params)
        tasks = tasks.select {|t| current_person.has_permission?(t.permission, asset)}
        return forbidden! if tasks.empty? && !current_person.has_permission?(:perform_task, asset)
        present_partial tasks, :with => Entities::Task
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

      # changing make_order_with_parameters to avoid sql injection
      def make_order_with_parameters(object, method, params)
        order = "created_at DESC"
        unless params[:order].blank?
          if params[:order].include? '\'' or params[:order].include? '"'
            order = "created_at DESC"
          elsif ['RANDOM()', 'RANDOM'].include? params[:order].upcase
            order = 'RANDOM()'
          else
            field_name, direction = params[:order].split(' ')
            assoc = object.class.reflect_on_association(method.to_sym)
            if !field_name.blank? and assoc
              if assoc.klass.attribute_names.include? field_name
                if direction.present? and ['ASC','DESC'].include? direction.upcase
                  order = "#{field_name} #{direction.upcase}"
                end
              end
            end
          end
        end
        return order
      end

      def make_timestamp_with_parameters_and_method(params, method)
        timestamp = nil
        if params[:timestamp]
          datetime = DateTime.parse(params[:timestamp])
          table_name = method.to_s.singularize.camelize.constantize.table_name
          timestamp = "#{table_name}.updated_at >= '#{datetime}'"
        end

        timestamp
      end

      def by_reference(scope, params)
        reference_id = params[:reference_id].to_i == 0 ? nil : params[:reference_id].to_i
        if reference_id.nil?
          scope
        else
          created_at = scope.find(reference_id).created_at
          scope.send("#{params.key?(:oldest) ? 'older_than' : 'younger_than'}", created_at)
         end
      end

      def by_categories(scope, params)
        category_ids = params[:category_ids]
        if category_ids.nil?
          scope
        else
          scope.joins(:categories).where(:categories => {:id => category_ids})
        end
      end

      def select_filtered_collection_of(object, method, params)
        conditions = make_conditions_with_parameter(params)
        order = make_order_with_parameters(object,method,params)
        timestamp = make_timestamp_with_parameters_and_method(params, method)

        objects = object.send(method)
        objects = by_reference(objects, params)
        objects = by_categories(objects, params)

        objects = objects.where(conditions).where(timestamp).reorder(order)

        params[:page] ||= 1
        params[:per_page] ||= limit
        paginate(objects)
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
          cant_be_saved_request!(key) if obj.find_by(key.to_s => params[key])
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

      def not_found!
        render_api_error!('404 Not found', 404)
      end

      def forbidden!
        render_api_error!('403 Forbidden', 403)
      end

      def cant_be_saved_request!(attribute)
        message = _("(Invalid request) %s can't be saved") % attribute
        render_api_error!(message, 400)
      end

      def bad_request!(attribute)
        message = _("(Invalid request) %s not given") % attribute
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

      # javascript_console_message is supposed to be executed as console.log()
      def render_api_error!(user_message, status, log_message = nil, javascript_console_message = nil)
        message_hash = {'message' => user_message, :code => status}
        message_hash[:javascript_console_message] = javascript_console_message if javascript_console_message.present?
        log_msg = "#{status}, User message: #{user_message}"
        log_msg = "#{log_message}, #{log_msg}" if log_message.present?
        log_msg = "#{log_msg}, Javascript Console Message: #{javascript_console_message}" if javascript_console_message.present?
        logger.error log_msg unless Rails.env.test?
        error!(message_hash, status)
      end

      def render_api_errors!(messages)
        messages = messages.to_a if messages.class == ActiveModel::Errors
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
        @domain = Domain.by_name(request.host)
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

      def filter_disabled_plugins_endpoints
        not_found! if Noosfero::API::API.endpoint_unavailable?(self, @environment)
      end

      private

      def parser_params(params)
        parsed_params = {}
        params.map do |k,v|
          parsed_params[k.to_sym] = v if DEFAULT_ALLOWED_PARAMETERS.include?(k.to_sym)
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
