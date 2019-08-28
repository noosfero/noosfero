require 'base64'
require 'tempfile'
require 'recaptcha'

module Api
  module Helpers
    PRIVATE_TOKEN_PARAM = :private_token
    ALLOWED_PARAMETERS = [:parent_id, :from, :until, :content_type, :author_id, :identifier, :archived, :status]
    ALLOWED_KEY_PARAMETERS = {
      Article => [:path]
    }

    include SanitizeParams
    include Noosfero::Plugin::HotSpot
    include ForgotPasswordHelper
    include SearchTermHelper
    include Recaptcha::Adapters::ControllerMethods

    def set_locale
      I18n.locale = (params[:lang] || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
    end

    def init_noosfero_plugins
      plugins
    end

    def session
      @session ||= Session.find_by(session_id: cookies[:_noosfero_session])
      @session
    end

    def reset_session
      cookies.delete('_noosfero_api_session')
      cookies.delete(:auth_token)
      session.destroy unless session.nil?
      logout
    end

    def set_current_user
      private_token = (params[PRIVATE_TOKEN_PARAM] || headers['Private-Token']).to_s
      @current_user ||= User.where(private_token: private_token).includes(:person).first unless private_token.blank?
      @current_user ||= plugins.dispatch("api_custom_login", request).first
      @current_user = session.user if @current_user.blank? && session.present?
      @current_user
    end

    def current_user
      @current_user
    end

    def current_person
      @person ||= current_user.person unless current_user.nil?
      @person
    end

    def is_admin?(environment)
      return false unless current_user
      return current_person.is_admin?(environment)
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
          fields = JSON.parse((params.to_hash[:fields] || params.to_hash['fields']).to_json)
          if fields.present?
            fields = fields.symbolize_keys
            options.merge!(:only => fields[:only]) if fields[:only].present?
            options.merge!(:except => fields[:except]) if fields[:except].present?
          end
        rescue
          fields = params[:fields]
          fields = fields.split(',') if fields.kind_of?(String)
          options[:only] = Array.wrap(fields)
        end
      end
      if params[:count].to_s == 'true' && model.respond_to?(:size)
        value = {:count => model.size}
        present value
      else
        present model, options
      end
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

    def parse_parent_id(parent_id)
      return nil if parent_id.blank?
      parent_id
    end

    def find_article(articles, params)
      conditions = make_conditions_with_parameter(params, Article)
      article = articles.find_by(conditions)
      not_found! if article.nil?
      article.display_to?(current_person) ? article : forbidden!
    end

    def post_article(asset, params)
      return forbidden! unless current_person.can_post_content?(asset)

      klass_type = params[:content_type] || params[:article].delete(:type) || TextArticle.name
      return forbidden! unless klass_type.constantize <= Article

      if params[:article][:uploaded_data].present?
        params[:article][:uploaded_data] = ActionDispatch::Http::UploadedFile.new(params[:article][:uploaded_data])
      end

      article = klass_type.constantize.new(params[:article])
      article.last_changed_by = current_person
      article.created_by= current_person
      article.profile = asset

      if !article.save
        render_model_errors!(article.errors)
      end
      present_partial article, :with => Entities::Article
    end

    def present_article(asset)
      article = find_article(asset.articles, params)
      present_partial article, with: Entities::Article, params: params, current_person: current_person
    end

    def present_articles_for_asset(asset, method_or_relation = 'articles')
      articles = find_articles(asset, method_or_relation)
      present_articles(articles)
    end

    def present_articles(articles)
      present_partial paginate(articles), :with => Entities::Article, :params => params, current_person: current_person
    end

    def find_articles(asset, method_or_relation = 'articles')
      articles = select_filtered_collection_of(asset, method_or_relation, params)
      if current_person.present?
        articles = articles.accessible_to(current_person)
      else
        articles = articles.published
      end
      articles
    end

    def find_task(asset, method_or_relation, id)
      task = is_a_relation?(method_or_relation) ? method_or_relation : asset.send(method_or_relation)
      task = task.find_by_id(id)
      not_found! if task.blank?
      current_person.has_permission?(task.permission, asset) ? task : forbidden!
    end

    def post_task(asset, params)
      klass_type= params[:content_type].nil? ? 'Task' : params[:content_type]
      return forbidden! unless klass_type.constantize <= Task
      return forbidden! if !current_person.has_permission?(:perform_task, asset)

      task = klass_type.constantize.new(params[:task])
      task.requestor_id = current_person.id
      task.target_id = asset.id
      task.target_type = 'Profile'

      if !task.save
        render_model_errors!(task.errors)
      end
      present_partial task, :with => Entities::Task
    end

    def find_tasks(asset, method_or_relation = 'tasks')
      return forbidden! if !current_person.has_permission?(:perform_task, asset)
      tasks = select_filtered_collection_of(asset, method_or_relation, params)
      tasks = tasks.select {|t| current_person.has_permission?(t.permission, asset)}
      tasks
    end

    def present_task(asset, method_or_relation = 'tasks')
      task = find_task(asset, method_or_relation, params[:id])
      present_partial task, :with => Entities::Task
      if task.kind_of?(AbuseComplaint)
        present_partial task, :with => Entities::AbuseComplaint
      else
        present_partial task, :with => Entities::Task
      end
    end

    def present_tasks_for_asset(asset, method_or_relation = 'tasks')
      tasks = find_tasks(asset, method_or_relation)
      present_tasks(tasks)
    end

    def present_tasks(tasks)
      present_partial tasks, :with => Entities::Task
    end

    ###########################
    #        Activities       #
    ###########################
    def find_activities(asset, method_or_relation = 'tracked_notifications')

      not_found! if asset.blank? || asset.secret || !asset.visible
      forbidden! unless asset.display_private_info_to?(current_person)
      if method_or_relation == 'activities'
        activities = select_filtered_collection_of(asset, method_or_relation, params)
        activities = activities.map(&:activity)
      else
        activities = select_filtered_collection_of(asset, method_or_relation, params)
      end
      activities
    end

    def present_activities_for_asset(asset, method_or_relation = 'tracked_notifications')
      tasks = find_activities(asset, method_or_relation)
      present_activities(tasks)
    end

    def present_activities(activities)
      present_partial activities, :with => Entities::Activity, :current_person => current_person
    end

    ###########################
    #          Tags           #
    ###########################

    def find_tags(asset, method_or_relation = 'tags')
      tags = select_filtered_collection_of(asset, method_or_relation, params)
      tags
    end

    def present_tags_for_asset(asset, method_or_relation = 'tags')
      tags = find_tags(asset, method_or_relation)
      present_tags(tags)
    end

    def present_tags(tags)
      present_partial tags, :with => Entities::Tag, :current_person => current_person
    end

    ###########################
    #      Common Methods     #
    ###########################

    def make_conditions_with_parameter(params = {}, class_type = nil)

      parsed_params = class_type.nil? ? parser_params(params) : parser_params_by_type(class_type, params)
      conditions = {}
      from_date = DateTime.parse(parsed_params.delete(:from)) if parsed_params[:from]
      until_date = DateTime.parse(parsed_params.delete(:until)) if parsed_params[:until]

      conditions[:type] = parse_content_type(parsed_params.delete(:content_type)) unless parsed_params[:content_type].nil?

      conditions[:created_at] = period(from_date, until_date) if from_date || until_date

      conditions[:parent_id] = parse_parent_id(parsed_params.delete(:parent_id)) if parsed_params.key? :parent_id

      conditions.merge!(parsed_params)

      conditions
    end

    # changing make_order_with_parameters to avoid sql injection
    def make_order_with_parameters(params, class_type)
      return_type = class_type == '' ? '' : (class_type.respond_to?(:table_name) ? class_type.table_name + '.' : '')
      
      order = "#{return_type}created_at DESC"
      unless params[:order].blank?
        if params[:order].include? '\'' or params[:order].include? '"'
          order = "#{return_type}created_at DESC"
        elsif ['RANDOM()', 'RANDOM'].include? params[:order].upcase
          order = 'RANDOM()'
        else
          field_name, direction = params[:order].split(' ')
          if !field_name.blank? and class_type
            if class_type.respond_to?(:attribute_names) && (class_type.attribute_names.include? field_name)
              if direction.present? and ['ASC','DESC'].include? direction.upcase
                order = "#{return_type}#{field_name} #{direction.upcase}"
              end
            end
          end
        end
      end
      return order
    end

    def make_timestamp_with_parameters_and_method(params, class_type)
      timestamp = nil
      if params[:timestamp]
        datetime = DateTime.parse(params[:timestamp]).utc
        table_name = class_type.table_name
        date_atrr = class_type.attribute_names.include?('updated_at') ? 'updated_at' : 'created_at'
        timestamp = "#{table_name}.#{date_atrr} >= '#{datetime}'"
      end

      timestamp
    end

    def by_period(scope, params, class_type, attribute)
      return scope if (class_type == NilClass || class_type.is_a?(String))
      from_param = "from_#{attribute}".to_sym
      until_param = "until_#{attribute}".to_sym
      from_date = DateTime.parse(params.delete(from_param)) if params[from_param]
      until_date = DateTime.parse(params.delete(until_param)) if params[until_param]
      table_name = class_type.table_name

      if class_type.new.is_a?(Event)
        scope = scope.where(" (#{table_name}.#{attribute} >= ?) OR (#{table_name}.#{attribute} iS NULL)", from_date) unless from_date.nil?
        scope = scope.where("#{table_name}.#{attribute} <= ?", until_date) unless until_date.nil?
      else 
        scope = scope.where("#{table_name}.created_at >= ?", from_date) if !from_date.nil? && until_date.nil?
        scope = scope.where("#{table_name}.created_at <= ?", until_date) if !until_date.nil? && from_date.nil?
        scope = scope.where("#{table_name}.created_at BETWEEN ? AND ?", from_date, until_date) if !until_date.nil? && !from_date.nil?
      end
      scope
    end

    def by_roles(scope, params)
      role_ids = params[:roles]
      if role_ids.nil?
        scope
      else
        scope.by_role(role_ids)
      end
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

    def select_filtered_collection_of(object, method_or_relation, params)

      conditions = make_conditions_with_parameter(params)
      assoc_class = extract_associated_classname(object, method_or_relation, conditions)

      order = make_order_with_parameters(params, assoc_class)
      timestamp = make_timestamp_with_parameters_and_method(params, assoc_class)

      objects = is_a_relation?(method_or_relation) ? method_or_relation : object.send(method_or_relation)
      objects = by_reference(objects, params)
      objects = by_categories(objects, params)
      objects = by_roles(objects, params)

      [:start_date, :end_date].each { |attribute| objects = by_period(objects, params, assoc_class, attribute) }

      objects = objects.where(conditions).where(timestamp)

      if params[:search].present? || params[:tag].present?
        asset = objects.model.name.underscore.pluralize
        objects = find_by_contents(asset, object, objects, params[:search], {:page => 1}, tag: params[:tag])[:results].reorder(order)
      else 
        objects = objects.reorder(order)
      end

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
    #           response helpers             #
    ##########################################

    def not_found!
      render_api_error!('404 Not found', Api::Status::Http::NOT_FOUND)
    end

    def forbidden!
      render_api_error!('403 Forbidden', Api::Status::Http::FORBIDDEN)
    end

    def cant_be_saved_request!(attribute)
      message = _("(Invalid request) %s can't be saved").html_safe % attribute
      render_api_error!(message, Api::Status::Http::BAD_REQUEST)
    end

    def bad_request!(attribute)
      message = _("(Invalid request) %s not given").html_safe % attribute
      render_api_error!(message, Api::Status::Http::BAD_REQUEST)
    end

    def something_wrong!
      message = _("Something wrong happened")
      render_api_error!(message, Api::Status::Http::BAD_REQUEST)
    end

    def unauthorized!
      render_api_error!(_('Unauthorized'), Api::Status::Http::UNAUTHORIZED)
    end

    def not_allowed!
      render_api_error!(_('Method Not Allowed'), Api::Status::Http::METHOD_NOT_ALLOWED)
    end

    def render_api_error!(user_message, status = Api::Status::Http::BAD_REQUEST)
      log_message = "#{status}, User message: #{user_message}"
      logger.error log_message unless Rails.env.test?
      msg = {
        :success => false,
        :message => user_message,
        :code => status
      }
      error!(msg, status)
    end

    def render_model_errors!(active_record_errors)
      message_hash = {}
      if active_record_errors.details
        message_hash[:errors] = active_record_errors.details
        message_hash[:errors].each do |field, errors|
          full_messages = active_record_errors.full_messages_for(field)
          errors.each_with_index {|error, i| error[:full_message] = full_messages[i] }
        end
      end
      error!(message_hash, Api::Status::Http::UNPROCESSABLE_ENTITY)
    end

    protected

    def set_session_cookie
      if @current_user.present? && session.present?
        session.data['user'] = @current_user.id
	session.save!
      end
    end

    def setup_multitenancy
      Noosfero::MultiTenancy.setup!(request.host)
    end

    def detect_stuff_by_domain
      @domain_hash ||= {}
      @domain_hash[request.host] ||= { domain: Domain.by_name(request.host)}
      @domain = @domain_hash[request.host][:domain]
      if @domain.nil?
        @domain_hash[request.host][:environment] ||= Environment.default
	@environment = @domain_hash[request.host][:environment]
        if @environment.nil? && Rails.env.development?
          # This should only happen in development ...
          @environment = Environment.create!(name: "Noosfero", is_default: true)
        end
      else
        @domain_hash[request.host][:environment] ||= @domain.environment
	@environment = @domain_hash[request.host][:environment]
      end
    end

    def filter_disabled_plugins_endpoints
      not_found! if Api::App.endpoint_unavailable?(self, @environment)
    end

    def asset_with_image params
      asset_with_custom_image(:image, params)
    end

    def asset_with_custom_image(field, params)
      builder_field = "#{field}_builder".to_sym
      if !params.nil? && params.has_key?(builder_field)
        asset_api_params = params
        asset_api_params[builder_field] = base64_to_uploadedfile(asset_api_params[builder_field])
        return asset_api_params
      end
      params
    end

    def asset_with_images params
      return params if params.nil? || !params.has_key?(:images_builder)
      asset_api_params = params
      asset_api_params[:images_builder] = asset_api_params[:images_builder].map do |image_builder|
        image_builder[:tempfile] ? base64_to_uploadedfile(image_builder) : image_builder
      end
      asset_api_params
    end

    def base64_to_uploadedfile(base64_image)
      tempfile = base64_to_tempfile base64_image
      converted_image = base64_image
      converted_image[:tempfile] = tempfile
      return {uploaded_data: ActionDispatch::Http::UploadedFile.new(converted_image)}
    end

    def base64_to_tempfile base64_image
      base64_img_str = base64_image[:tempfile]
      decoded_base64_str = Base64.decode64(base64_img_str)
      tempfile = Tempfile.new(base64_image[:filename])
      tempfile.write(decoded_base64_str.encode("ascii-8bit").force_encoding("utf-8"))
      tempfile.rewind
      tempfile
    end
    private

    def extract_associated_classname(object, method_or_relation, conditions)
      if is_a_relation?(method_or_relation)
        method_or_relation.blank? ? '' : method_or_relation.where(conditions).first.class
      else
        object.send(method_or_relation).where(conditions).first.class
      end
    end

    def is_a_relation?(method_or_relation)
      method_or_relation.kind_of?(ActiveRecord::Relation)
    end


    def parser_params(params)
      parsed_params = {}
      params.map do |k,v|
        parsed_params[k.to_sym] = v if ALLOWED_PARAMETERS.include?(k.to_sym)
      end
      parsed_params
    end

    def parser_params_by_type(class_type, params)
      parsed_params = parser_params(params)
      key = params[:key].to_sym if params[:key].present?
      if key.present? && ALLOWED_KEY_PARAMETERS[class_type].include?(key)
         parsed_params[key] = params[:id]
      else
         parsed_params[:id] = params[:id]
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

    def settings(owner)
      blocks = owner.available_blocks(current_person)
      settings = {:available_blocks => blocks}
      settings
    end

  end
end
