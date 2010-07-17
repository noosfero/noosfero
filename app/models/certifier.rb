class Certifier < ActiveRecord::Base

  belongs_to :environment

  def link
    self[:link] || ''
  end
end
