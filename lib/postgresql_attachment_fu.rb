module PostgresqlAttachmentFu

  module ClassMethods
    def postgresql_attachment_fu
      send :include, InstanceMethods
    end
  end

  module InstanceMethods
    def full_filename(thumbnail = nil)
      file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
      file_system_path = File.join(file_system_path, ActiveRecord::Base.connection.schema_search_path) if ActiveRecord::Base.postgresql?
      File.join(RAILS_ROOT, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
    end
  end

end

ActiveRecord::Base.send(:extend, PostgresqlAttachmentFu::ClassMethods)
