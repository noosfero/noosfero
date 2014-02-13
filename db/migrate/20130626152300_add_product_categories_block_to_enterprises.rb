class AddProductCategoriesBlockToEnterprises < ActiveRecord::Migration
  def self.up
    Enterprise.find_each do |enterprise|
      enterprise.boxes << Box.new while enterprise.boxes.length < 2
      enterprise.boxes[1].blocks << ProductCategoriesBlock.new
    end
  end

  def self.down
    Enterprise.find_each do |enterprise|
      enterprise.boxes.each do |box|
        box.blocks.each do |block|
          block.destroy if block.class == ProductCategoriesBlock
        end
      end
    end
  end
end
