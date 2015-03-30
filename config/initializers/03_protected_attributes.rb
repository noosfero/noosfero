class Delayed::Backend::ActiveRecord::Job
  attr_accessible *self.column_names, :payload_object
end
