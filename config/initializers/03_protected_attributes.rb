class Delayed::Backend::ActiveRecord::Job
  # rake db:schema:load run?
  if self.table_exists?
    attr_accessible *self.column_names, :payload_object
  end
end
