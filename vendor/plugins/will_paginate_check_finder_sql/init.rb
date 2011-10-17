# monkey patch to fix WillPaginate bug
# this was solved in will_paginate 3.x.pre, then remove this patch when upgrade to it
#
# http://sod.lighthouseapp.com/projects/17958/tickets/120-paginate-association-with-finder_sql-raises-typeerror
require_dependency 'will_paginate'

WillPaginate::Finder::ClassMethods.module_eval do
  def paginate_with_finder_sql(*args)
    if respond_to?(:proxy_reflection) && !proxy_reflection.options[:finder_sql].nil?
      # note: paginate_by_sql ignores the blocks. So don't pass the block
      paginate_by_sql(@finder_sql, args.extract_options!)
    else
      paginate_without_finder_sql(*args)
    end
  end
  # patch to deal with the custom_sql scenario
  alias_method_chain :paginate, :finder_sql
end
