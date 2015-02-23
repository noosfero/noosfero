class FavoriteEnterprisePerson < ActiveRecord::Base

  self.table_name = :favorite_enteprises_people

  belongs_to :enterprise
  belongs_to :person

end
