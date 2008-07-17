class << ActiveRecord::Base

  def acts_as_searchable(options = {})
    acts_as_ferret({ :remote => true }.merge(options))
    def find_by_contents(query, ferret_options = {}, db_options = {})
      if ferret_options[:page]
        db_options[:page] = ferret_options.delete(:page)
      end
      if ferret_options[:per_page]
        db_options[:per_page] = ferret_options.delete(:per_page)
      end
      
      ids = find_ids_with_ferret(query, ferret_options)[1].map{|r|r[:id].to_i}
      if db_options[:conditions]
        db_options[:conditions] = sanitize_sql_for_conditions(db_options[:conditions]) + " and #{table_name}.id in (#{ids.join(', ')})"
      else
        db_options[:conditions] = "#{table_name}.id in (#{ids.join(', ')})"
      end

      db_options[:page] ||= 1
      paginate(:all, db_options)
    end
  end

end
