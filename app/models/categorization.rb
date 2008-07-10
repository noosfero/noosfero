module Categorization

  def add_category_to_object(category, object)
    connection.execute("insert into #{table_name} (category_id, #{object_id_column}) values(#{category.id}, #{object.id})")

    c = category.parent
    while !c.nil? && !self.find(:first, :conditions => {object_id_column => object, :category_id => c})
      connection.execute("insert into #{table_name} (category_id, #{object_id_column}, virtual) values(#{c.id}, #{object.id}, 1>0)")
      c = c.parent
    end
  end

  def remove_all_for(object)
    self.delete_all(object_id_column => object.id)
  end

end
