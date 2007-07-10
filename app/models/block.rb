#It's the class that define the block's content will be displayed on box in a determined web
class Block < ActiveRecord::Base
  include ActionView::Helpers::TagHelper
  belongs_to :box

  #<tt>position</tt> codl not be nil and must be an integer
  validates_numericality_of :position, :only_integer => true , :message => _('%{fn} must be composed only of integers')

  # A block must be associated to a box
  validates_presence_of :box_id 

  # Method that define the html code displayed on the box.
  # This method cannot be used directly it will be redefined by the children classes
  def to_html
    raise _("This is a main class, don't use it")
  end

  # This method always return false excepted when redefined by the MainBlock class. It mean the current block it's not the result of a
  # controller action.
  #
  # The child class MainBlock subscribes this method returning true.
  def main?
    false
  end

end
