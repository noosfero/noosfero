class CreateReportedImage < ActiveRecord::Migration
  def self.up
    create_table :reported_images do |t|
      t.integer :size
      t.string  :content_type
      t.string  :filename
      t.integer :height
      t.integer :width
      t.references :abuse_report
    end
  end

  def self.down
    drop_table :reported_images
  end
end
