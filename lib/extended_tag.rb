class Tag
  def descendents
    children.inject([]){|des , child| des + child.descendents << child} 
  end

  def find_tag(*args)
    find(*args).select{|t|!t.pending?}
  end

end
