module ActsAsHavingImage

  module ClassMethods
    def acts_as_having_image(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      image_field = (options[:field] || :image).to_sym

      belongs_to image_field, dependent: :destroy, class_name: 'Image'
      scope "with_#{image_field}", -> { where "#{table_name}.#{image_field}_id IS NOT NULL" }
      scope "without_#{image_field}", -> { where "#{table_name}.#{image_field}_id IS NULL" }
      attr_accessible "#{image_field}_builder"
      include ActsAsHavingImage

      define_method "#{image_field}_builder=" do |img|
        if self[image_field] && self[image_field].id == img[:id]
          self[image_field].attributes = img
        else
          send("build_#{image_field}", img)
        end unless img[:uploaded_data].blank?
        if img[:remove_image] == 'true'
          self["#{image_field}_id"] = nil
        end
      end
    end
  end

end
