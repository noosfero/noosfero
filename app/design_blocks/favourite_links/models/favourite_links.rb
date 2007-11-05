class FavouriteLinks < Design::Block

  def self.description
    _('Favourite Links')
  end

  def limit_number= value
    self.settings[:limit_number] = value.to_i
  end

  def limit_number
    self.settings[:limit_number] || 5
  end

  def favourite_links_limited
    self.favourite_links.first(self.limit_number)
  end

  def favourite_links
    self.settings[:favourite_links] ||= []
  end

  def delete_link link
    self.settings[:favourite_links].reject!{ |item| item == link }
    self.save
  end

  def favourite_link
    nil
  end

  def favourite_link= link
    self.favourite_links.push(link)
    self.favourite_links.uniq!
  end

end
