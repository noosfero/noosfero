ActiveRecord::Calculations.class_eval do
  def count_with_distinct column_name=self.primary_key
    if column_name
      distinct.count_without_distinct column_name
    else
      count_without_distinct
    end
  end
  alias_method_chain :count, :distinct
end
