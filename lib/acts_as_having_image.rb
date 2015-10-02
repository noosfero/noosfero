module ActsAsHavingImage

  module ClassMethods
    def acts_as_having_image
      belongs_to :image, dependent: :destroy
      scope :with_image, -> { where "#{table_name}.image_id IS NOT NULL" }
      scope :without_image, -> { where "#{table_name}.image_id IS NULL" }
      attr_accessible :image_builder
      include ActsAsHavingImage
    end
  end

  def image_builder=(img)
    if image && image.id == img[:id]
      image.attributes = img
    else
      build_image(img)
    end unless img[:uploaded_data].blank?
    if img[:remove_image] == 'true'
      self.image_id = nil
    end
  end

end

ActiveRecord::Base.extend(ActsAsHavingImage::ClassMethods)
