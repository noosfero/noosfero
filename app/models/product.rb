class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :enterprise_id
  validates_numericality_of :price, :allow_nil => true

  has_one :image, :as => :owner

  after_update :save_image

  def image_builder=(img)
    if image && image.id == img[:id]
      image.attributes = img
    else
      build_image(img)
    end
  end

  def save_image
    image.save if image
  end
end
