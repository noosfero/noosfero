class ChangeHighlightsBlockAttribute < ActiveRecord::Migration
  def up
    HighlightsBlock.all.map do |block|
      block.settings[:block_images] = block.settings[:images]
      block.settings.delete(:images)
      block.save
    end
  end

  def down
    HighlightsBlock.all.map do |block|
      block.settings[:images] = block.settings[:block_images]
      block.settings.delete(:block_images)
      block.save
    end
  end
end
