class Block < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  belongs_to :box

  #<tt>position</tt> codl not be nil and must be an integer
  validates_numericality_of :position, :only_integer => true , :message => _('%{fn} must be composed only of integers')

  # A block must be associated to a box
  validates_presence_of :box_id 

  def to_html
    #TODO Upgrade this test
#    raise _("This is a main class, don't use it")
  end

  def main?
    false
  end

end
