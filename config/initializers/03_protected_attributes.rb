class Delayed::Backend::ActiveRecord::Job
  # rake db:schema:load run?
  # Do not hit the database if compiling assets
  if !Noosfero.compiling_assets? && self.table_exists?
    attr_accessible *self.column_names, :payload_object
  end
end
