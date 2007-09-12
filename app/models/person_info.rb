class PersonInfo < ActiveRecord::Base

  # FIXME: add file_column :photo

  belongs_to :person

  def summary
    [
      [ _('Name'), self.name ],
      [ _('Address'), self.address ],
      [ _('Contact Information'), self.contact_information ],
    ]
  end

end
