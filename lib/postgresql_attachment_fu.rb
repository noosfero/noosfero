module PostgresqlAttachmentFu

  module ClassMethods
    def postgresql_attachment_fu
      send :include, InstanceMethods
    end
  end

  module InstanceMethods
    def full_filename(thumbnail = nil)
      file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
      file_system_path = File.join(file_system_path, ApplicationRecord.connection.schema_search_path) if ApplicationRecord.postgresql? and Noosfero::MultiTenancy.on?
      Rails.root.join(file_system_path, *partitioned_path(thumbnail_name_for(thumbnail))).to_s
    end
  end

end

ApplicationRecord.extend PostgresqlAttachmentFu::ClassMethods

