class FavoriteLinks < Design::Block

  def self.description
    _('Favorite Links')
  end

  def limit_number= value
    self.settings[:limit_number] = value.to_i
  end

  def limit_number
    self.settings[:limit_number] || 5
  end

  def favorite_links_limited
    self.favorite_links.first(self.limit_number)
  end

  def favorite_links
    self.settings[:favorite_links] ||= []
  end

  def delete_link link
    self.settings[:favorite_links].reject!{ |item| item == link }
    self.save
  end

  def favorite_link
    nil
  end

  def favorite_link= link
    self.favorite_links.push(link)
    self.favorite_links.uniq!
  end

end
