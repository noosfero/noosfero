class Block < ActiveRecord::Base
  belongs_to :box

  #<tt>position</tt> codl not be nil and must be an integer
  validates_numericality_of :position, :only_integer => true , :message => _('%{fn} must be composed only of integers')

  # A block must be associated to a box
  validates_presence_of :box_id 

  def to_html
    str = "content_tag(:p, 'bli')"
    return str
  end

end
