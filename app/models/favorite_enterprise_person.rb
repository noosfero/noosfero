class FavoriteEnterprisePerson < ApplicationRecord

  attr_accessible :person, :enterprise

  track_actions :favorite_enterprise, :after_create, keep_params: [:enterprise_name, :enterprise_url], if: proc{ |f| f.notifiable? }

  belongs_to :enterprise, optional: true
  belongs_to :person, optional: true

  after_create do |favorite|
    favorite.person.follow(favorite.enterprise, Circle.find_or_create_by(:person => favorite.person, :name =>_('favorites'), :profile_type => 'Enterprise'))
  end

  protected

  def notifiable?
    self.enterprise.display_to?
  end

  def enterprise_name
    self.enterprise.short_name(nil)
  end
  def enterprise_url
    self.enterprise.url
  end

end
