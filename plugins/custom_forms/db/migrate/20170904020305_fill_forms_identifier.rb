class FillFormsIdentifier < ActiveRecord::Migration
  def self.up
    CustomFormsPlugin::Form.where('identifier is null').each do |form|
      form.update(identifier: form.slug)
    end
  end

  def self.down
    CustomFormsPlugin::Form.where('identifier is not null').each do |form|
      form.update(identifier: nil)
    end
  end
end
