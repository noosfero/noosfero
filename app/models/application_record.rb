class ApplicationRecord < ActiveRecord::Base

  extend PostgresqlAttachmentFu::ClassMethods
  extend ActiveRecord::Attributes

  self.abstract_class       = true
  self.store_full_sti_class = true

  # an ActionView instance for rendering views on models
  def self.action_view
    @action_view ||= begin
      view_paths = ::ActionController::Base.view_paths
      action_view = ::ActionView::Base.new view_paths
      # for using Noosfero helpers inside render calls
      action_view.extend ::ApplicationHelper
      action_view
    end
  end

  # default value needed for the above ActionView
  def to_partial_path
    self.class.name.underscore
  end

  alias_method :meta_cache_key, :cache_key
  def cache_key
    key = [Noosfero::VERSION, meta_cache_key]
    key.unshift ApplicationRecord.connection.schema_search_path
    key.join('/')
  end

  def self.like_search(query, options={})
    if defined?(self::SEARCHABLE_FIELDS) || options[:fields].present?
      fields_per_table = {}
      fields_per_table[table_name] = (options[:fields].present? ? options[:fields] : self::SEARCHABLE_FIELDS.keys.map(&:to_s)) & column_names

      if options[:joins].present?
        join_asset = options[:joins].to_s.classify.constantize
        if defined?(join_asset::SEARCHABLE_FIELDS) || options[:fields].present?
          fields_per_table[join_asset.table_name] = (options[:fields].present? ? options[:fields] : join_asset::SEARCHABLE_FIELDS.keys.map(&:to_s)) & join_asset.column_names
        end
      end

      query = query.downcase.strip
      fields_per_table.delete_if { |table,fields| fields.blank? }
      conditions = fields_per_table.map do |table,fields|
        fields.map do |field|
          "lower(#{table}.#{field}) LIKE '%#{query}%'"
        end.join(' OR ')
      end.join(' OR ')

      if options[:joins].present?
        joins(options[:joins]).where(conditions)
      else
        where(conditions)
      end

    else
      raise "No searchable fields defined for #{self.name}"
    end
  end

  def self.serialized_attributes(model)
    model.columns.select do |column|
      model.type_for_attribute(column.name).is_a?(::ActiveRecord::Type::Serialized)
    end.inject({}) do |hash, column|
      hash[column.name.to_s] = model.type_for_attribute(column.name).coder
      hash
    end
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end

  def xml_http_request(request_method, action, parameters = nil, session = nil, flash = nil)
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    @request.env['HTTP_ACCEPT'] ||=  [Mime::JS, Mime::HTML, Mime::XML, 'text/xml', Mime::ALL].join(', ')
    __send__(request_method, action, parameters, session, flash).tap do
      @request.env.delete 'HTTP_X_REQUESTED_WITH'
      @request.env.delete 'HTTP_ACCEPT'
    end
  end
  alias xhr :xml_http_request

end

