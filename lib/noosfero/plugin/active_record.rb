class Noosfero::Plugin::ActiveRecord < ActiveRecord::Base
  def self.table_name
    self.name.gsub('::','_').underscore.pluralize
  end
end
