class MoveValuesOfVisibleFieldToDisplayField < ActiveRecord::Migration
  def self.up
    Block.all.each do |block|
      visible = block.settings.delete(:visible)
      if visible == false
        block.settings[:display] = 'never'
        block.save!
      else
        if block.settings[:display].blank?
          block.settings[:display] = 'always'
          block.save!
        end
      end
    end
  end

  def self.down
    say "Nothing to do!"
  end
end
