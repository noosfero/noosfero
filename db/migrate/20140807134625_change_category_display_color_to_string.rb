class ChangeCategoryDisplayColorToString < ActiveRecord::Migration

  COLORS = ['ffa500', '00FF00', 'a020f0', 'ff0000', '006400', '191970', '0000ff', 'a52a2a', '32cd32', 'add8e6', '483d8b', 'b8e9ee', 'f5f5dc', 'ffff00', 'f4a460']

  def self.up
    change_table :categories do |t|
      t.string :display_color_tmp, :limit => 6
    end

    COLORS.each_with_index do |color, i|
      Category.update_all({:display_color_tmp => color}, {:display_color => i+1})
    end

    change_table :categories do |t|
      t.remove :display_color
      t.rename :display_color_tmp, :display_color
    end
  end

  def self.down
    puts "WARNING: only old defined colors will be reverted"

    change_table :categories do |t|
      t.integer :display_color_tmp
    end

    COLORS.each_with_index do |color, i|
      Category.update_all({:display_color_tmp => i+1}, {:display_color => color})
    end

    change_table :categories do |t|
      t.remove :display_color
      t.rename :display_color_tmp, :display_color
    end
  end
end
