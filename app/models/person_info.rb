class PersonInfo < ActiveRecord::Base

  # FIXME: add file_column :photo

  belongs_to :person

  def summary
    [
      [ PersonInfo.columns_hash['name'].human_name, self.name ],
      [ PersonInfo.columns_hash['address'].hunam_name, self.address ],
      [ PersonInfo.columns_hash['contact_information'], self.contact_information ],
    ]
  end

end
