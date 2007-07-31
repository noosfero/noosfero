module Design

  # A design is composed of one or more boxes. Each box defines an area in the
  # screen identified by a number and possibly by a name. A box contains inside
  # it several Block objects, and is owner by some other object, possibly one
  # from the application model.
  class Box < ActiveRecord::Base

    set_table_name 'design_boxes'

    has_many :blocks
    belongs_to :owner, :polymorphic => true
  
    validates_presence_of :owner
    validates_presence_of :name
  
    #we cannot have two boxs with the same number to the same owner
    validates_uniqueness_of :number, :scope => [:owner_type, :owner_id]
  
    #<tt>number</tt> could not be nil and must be an integer
    validates_numericality_of :number, :only_integer => true
    #TODO see the internationalization questions
    #, :message => _('%{fn} must be composed only of integers.')
  
    # Return all blocks of the current box object sorted by the position block
    def blocks_sort_by_position
      self.blocks.sort{|x,y| x.position <=> y.position}
    end
   
    def save
      self[:name] ||= "Box " + self.number.to_s
      super
    end
   
    def owner= owner
      self[:owner_type] = owner.class.to_s
      self[:owner_id] = owner.id
      n_boxes = self.owner.boxes.count if self.owner
      if !n_boxes.nil? 
        self[:number] ||= n_boxes == 0 ? 1 : n_boxes + 1 
      else
        self[:number] ||= nil
      end
    end
  
    def switch_number box
      throw :cant_switch_without_save if self[:id].nil? and (box.nil? or box.id.nil?)
  
      max_box = box.owner.boxes.count
      transaction do 
        n = self[:number]
        self[:number] = box.number
        box.number = max_box + 1
        box.save
        self.save
        box.number = n
        box.save  
      end
    end
  
  end
end
