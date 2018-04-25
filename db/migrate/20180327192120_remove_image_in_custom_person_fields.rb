class RemoveImageInCustomPersonFields < ActiveRecord::Migration

  def change
    Environment.all.each do |env|
      env.custom_person_fields.delete(:image)
      env.save
    end
  end
end
