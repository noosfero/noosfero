class FillFormsIdentifier < ActiveRecord::Migration
  def self.up
    CustomFormsPlugin::Form.where(['identifier = ?', '']).each do |form|
      form.update(identifier: form.slug)
    end
  end

  def self.down
    CustomFormsPlugin::Form.where(['identifier != ?', '']).each do |form|
      form.update(identifier: '')
    end
  end
end
