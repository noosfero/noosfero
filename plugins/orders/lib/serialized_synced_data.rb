module SerializedSyncedData

  def self.prepare_data _hash
    return {} unless _hash
    hash = {}; _hash.each do |key, value|
      next if value.blank?
      hash[key.to_sym] = value
    end
    hash
  end

  module ClassMethods

    def sync_serialized_field field, &block
      class_attribute :serialized_synced_fields unless self.respond_to? :serialized_synced_fields
      self.serialized_synced_fields ||= []
      self.serialized_synced_fields << field

      field_data = "#{field}_data".to_sym
      field_data_without_sync = "#{field_data}_without_sync".to_sym

      serialize field_data
      before_save "fill_#{field_data}"

      # Rails doesn't define getters/setter for attributes
      if not self.method_defined? field_data and field_data.to_s.in? self.column_names
        define_method field_data do
          self[field_data] || {}
        end
      else
        define_method "#{field_data}_with_sync_default" do
          self.send("#{field_data}_without_sync_default") || {}
        end
        alias_method_chain field_data, :sync_default
      end
      if not self.method_defined? "#{field_data}=" and field_data.to_s.in? self.column_names
        define_method "#{field_data}=" do |value|
          self[field_data] = SerializedSyncedData.prepare_data value
        end
      else
        define_method "#{field_data}_with_prepare=" do |value|
          self.send "#{field_data}_without_prepare=", SerializedSyncedData.prepare_data(value)
        end
        alias_method_chain "#{field_data}=", :prepare
      end

      # return data from foreign registry if any data was synced yet
      define_method "#{field_data}_with_sync" do
        current_data = self.send field_data_without_sync
        if current_data.present? then current_data else self.send "#{field}_synced_data" end
      end
      alias_method_chain field_data, :sync

      # get the data to sync as defined
      define_method "#{field}_synced_data" do
        source = self.send field
        if block_given?
          data = SerializedSyncedData.prepare_data instance_exec(source, &block)
        elsif source.is_a? ActiveRecord::Base
          data = SerializedSyncedData.prepare_data source.attributes
        elsif source.is_a? Array
          data = source.map{ |source| SerializedSyncedData.prepare_data source.attributes }
        end || {}
      end

      define_method "sync_#{field_data}" do
        value = self.send "#{field}_synced_data"
        current = self.send field_data
        value = current.deep_merge! value
        self.send "#{field_data}=", value
      end

      define_method "fill_#{field_data}" do
        return if self.send(field_data_without_sync).present?
        self.send "sync_#{field_data}"
      end

      include InstanceMethods
    end

  end

  module InstanceMethods

    def sync_serialized_data
      self.class.serialized_synced_fields.each do |field|
        self.send "sync_#{field}_data"
      end
    end

  end

end
