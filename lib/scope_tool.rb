module ScopeTool

  # Sum scope results by SQL, allowing post filtering of the group.
  def union(*scopes)
    model = scopes.first.klass.name.constantize
    scopes = scopes.map &:to_sql
    model.from "(\n#{scopes.join("\nUNION\n")}\n) as #{model.table_name}"
  end

  class << self
    # Allows to use `ScopeTool.method()` anywhere.
    include ScopeTool
  end

end
