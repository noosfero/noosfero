class FavoriteEnterprisePerson < ActiveRecord::Base

  attr_accessible :person, :enterprise

  track_actions :favorite_enterprise, :after_create, keep_params: [:enterprise_name, :enterprise_url], if: proc{ |f| f.is_trackable? }

  belongs_to :enterprise
  belongs_to :person

  protected

  def is_trackable?
    self.enterprise.public?
  end

  def enterprise_name
    self.enterprise.short_name(nil)
  end
  def enterprise_url
    self.enterprise.url
  end

end
