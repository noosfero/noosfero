module ActsAsHavingImage

  module ClassMethods
    def acts_as_having_image
      has_one :image, :as => 'owner'
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
