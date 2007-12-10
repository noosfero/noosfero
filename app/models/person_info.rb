class PersonInfo < ActiveRecord::Base

  belongs_to :person

  def summary
    ['name', 'contact_information', 'sex', 'birth_date', 'address', 'city', 'state', 'country'].map do |col|
      [ PersonInfo.columns_hash[col] && PersonInfo.columns_hash[col].human_name, self.send(col) ]
    end
  end

  def age
    a = Date.today.year - birth_date.year
    Date.today.yday >= birth_date.yday ? a : a-1
  end

end
