# based on https://rails.lighthouseapp.com/projects/8994/tickets/1266-order-add_index-statements-in-schemarb
# only needed for rails < 2.2 
if Rails::VERSION::STRING < "2.2.0"
  class ActiveRecord::SchemaDumper
    def indexes(table, stream)
      if (indexes = @connection.indexes(table)).any?

        add_index_statements = indexes.map do |index|
          statment_parts = [ ('add_index ' + index.table.inspect) ]
          statment_parts << index.columns.inspect
          statment_parts << (':name => ' + index.name.inspect)
          statment_parts << ':unique => true' if index.unique

            '  ' + statment_parts.join(', ')
        end

        stream.puts add_index_statements.sort.join("\n")
        stream.puts
      end
    end
  end
end
