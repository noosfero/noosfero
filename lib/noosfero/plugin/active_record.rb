class Noosfero::Plugin::ActiveRecord < ActiveRecord::Base

  def self.inherited(child)
    self.table_name = child.name.gsub('::','_').underscore.pluralize
  end

end
