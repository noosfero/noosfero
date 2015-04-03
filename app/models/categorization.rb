module Categorization

  def add_category_to_object(category, object)
    if !self.where(object_id_column => object, :category_id => category).first
      connection.execute("insert into #{table_name} (category_id, #{object_id_column}) values(#{category.id}, #{object.id})")

      c = category.parent
      while !c.nil? && !self.where(object_id_column => object, :category_id => c).first
        connection.execute("insert into #{table_name} (category_id, #{object_id_column}, virtual) values(#{c.id}, #{object.id}, 1>0)")
        c = c.parent
      end
    else
      connection.execute "update #{table_name} set virtual = (1!=1) where #{object_id_column} = #{object.id} and category_id = #{category.id}"
    end
  end

  def remove_all_for(object)
    self.delete_all(object_id_column => object.id)
  end

end
