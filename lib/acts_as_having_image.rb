module ActsAsHavingImage

  module ClassMethods
    def acts_as_having_image
      belongs_to :image, dependent: :destroy
      scope :with_image, :conditions => [ "#{table_name}.image_id IS NOT NULL" ]
      scope :without_image, :conditions => [ "#{table_name}.image_id IS NULL" ]
      self.send(:include, ActsAsHavingImage)
    end
  end

  def image_builder=(img)
    if image && image.id == img[:id]
      image.attributes = img
    else
      build_image(img)
    end unless img[:uploaded_data].blank?
  end

end

ActiveRecord::Base.extend(ActsAsHavingImage::ClassMethods)