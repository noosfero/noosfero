ActiveRecord::Calculations.class_eval do
  def count_with_distinct column_name=nil
    if column_name
      distinct.count_without_distinct column_name
    else
      count_without_distinct
    end
  end
end
