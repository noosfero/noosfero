module Design

  # Box ix the base class for most of the content elements. A Box is contaied
  # by a Block, which may contain several blocks.
  class Block < ActiveRecord::Base

    set_table_name 'design_blocks'

    belongs_to :box
  
    #<tt>position</tt> codl not be nil and must be an integer
    validates_numericality_of :position, :only_integer => true 
    #TODO see the internationalization
    #, :message => _('%{fn} must be composed only of integers')
  
    # A block must be associated to a box
    validates_presence_of :box_id 
  
    # This method always return false excepted when redefined by the MainBlock class. It mean the current block it's not the result of a
    # controller action.
    #
    # The child class MainBlock subscribes this method returning true.
    def main?
      false
    end
  
    # Method that define the content code displayed in the box.
    # This method cannot be used directly it will be redefined by the children classes
    def content
      raise "This is a main class, don't use it"
    end
  
  #TODO see if this method is needed
    def self.children
      @@block_children
    end
  
    private
    @@block_children = Array.new
  
    def self.inherited(subclass)
      @@block_children.push(subclass.to_s) unless @@block_children.include? subclass.to_s
    end
  
  end

end # END OF module Design
