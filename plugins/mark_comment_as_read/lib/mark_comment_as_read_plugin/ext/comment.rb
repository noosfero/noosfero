require_dependency 'comment'

class Comment

  has_many :read_comments, :class_name => 'MarkCommentAsReadPlugin::ReadComments'
  has_many :people, :through => :read_comments

  def mark_as_read(person)
    people << person
  end

  def mark_as_not_read(person)
    people.delete(person)
  end

  def marked_as_read?(person)
    person && people.where(id: person.id).first
  end

  def self.marked_as_read(person)
    joins(:read_comments).where(author_id: person.id)
  end

end
