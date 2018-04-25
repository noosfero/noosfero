module CroppedImage

  extend ActiveSupport::Concern

  included do
    attr_accessible :crop_x, :crop_y, :crop_w, :crop_h
    attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

    before_save :load_image_and_crop

    protected

    def load_image_and_crop
      if %w(.jpeg .jpg .png .gif .bmp).include? File.extname(temp_path)
        image = Magick::ImageList.new(temp_path)
        crop(image)
      end
    end

    def crop(image)
      if image && self.crop_x.present?
         x = crop_x.to_i
         y = crop_y.to_i
         w = crop_w.to_i
         h = crop_h.to_i
         image.crop!(x, y, w, h)
         image.write(temp_path)
         self.crop_x = nil
      end
    end
  end

end
