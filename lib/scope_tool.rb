module ScopeTool

  def union(*scopes)
    model = scopes.first.class_name.constantize
    scopes = scopes.map &:to_sql
    model.from "(\n#{scopes.join("\nUNION\n")}\n) as #{model.table_name}"
  end

  class << self
    include ScopeTool
  end

end
