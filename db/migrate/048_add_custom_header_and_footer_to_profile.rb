class AddCustomHeaderAndFooterToProfile < ActiveRecord::Migration

  TABLES = [ :profiles, :environments ]

  def self.up
    TABLES.each do |item|
      add_column item, :custom_header, :text
      add_column item, :custom_footer, :text
    end
  end

  def self.down
    TABLES.each do |item|
      remove_column item, :custom_header
      remove_column item, :custom_footer
    end
  end
end
