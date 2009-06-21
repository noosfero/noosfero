class << ActiveRecord::Base

  def acts_as_searchable(options = {})
    acts_as_ferret({ :remote => true }.merge(options))
    def find_by_contents(query, ferret_options = {}, db_options = {})
      pg_options = {}
      if ferret_options[:page]
        pg_options[:page] = ferret_options.delete(:page)
      end
      if ferret_options[:per_page]
        pg_options[:per_page] = ferret_options.delete(:per_page)
      end

      ferret_options[:limit] = :all
      
      # FIXME this is a HORRIBLE HACK
      ids = find_ids_with_ferret(query, ferret_options)[1][0..8000].map{|r|r[:id].to_i}

      if ids.empty?
        ids << -1
      end

      if db_options[:conditions]
        db_options[:conditions] = sanitize_sql_for_conditions(db_options[:conditions]) + " and #{table_name}.id in (#{ids.join(', ')})"
      else
        db_options[:conditions] = "#{table_name}.id in (#{ids.join(', ')})"
      end

      pg_options[:page] ||= 1
      result = find(:all, db_options)
      result.paginate(pg_options)
    end
  end

end
