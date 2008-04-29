class OrganizationInfo < ActiveRecord::Base
  belongs_to :organization
  
  validates_numericality_of :foundation_year, :only_integer => true, :allow_nil => true

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |info| ! info.contact_email.nil? })
                                                                                     
  xss_terminate :only => [ :acronym, :contact_person, :contact_email, :legal_form, :economic_activity, :management_information ]

  def summary
    # FIXME diplays too few fields
    [ 'acronym', 'foundation_year', 'contact_email'].map do |col|
      [ OrganizationInfo.columns_hash[col].human_name, self.send(col) ]
    end
  end
end
