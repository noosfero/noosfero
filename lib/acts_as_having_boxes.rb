module ActsAsHavingBoxes

  module ClassMethods
    def  acts_as_having_boxes
      has_many :boxes, -> { order :position }, as: :owner, dependent: :destroy
      self.send(:include, ActsAsHavingBoxes)
    end
  end

  module BlockArray
    def find(id)
      select { |item| item.id == id.to_i }.first
    end
  end

  def blocks(reload = false)
    if (reload)
      @blocks = nil
    end
    if @blocks.nil?
      @blocks = boxes.includes(:blocks).inject([]) do |acc,obj|
        acc.concat(obj.blocks)
      end
      @blocks.send(:extend, BlockArray)
    end
    @blocks
  end

  # returns 3 unless the class table has a boxes_limit column. In that case
  # return the value of the column.
  def boxes_limit layout_template = nil
    layout_template ||= self.layout_template
    @boxes_limit ||= LayoutTemplate.find(layout_template).number_of_boxes || 3
  end

end

ActiveRecord::Base.extend ActsAsHavingBoxes::ClassMethods
