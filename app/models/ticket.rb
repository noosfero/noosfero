class Ticket < Task

  serialize :data, Hash

  def data
    self[:data] ||= {}
  end

  def title
    data[:title]
  end

  def title= value
    data[:title] = value
  end

  def description
    data[:description]
  end

  def description= value
    data[:description] = value
  end

end
