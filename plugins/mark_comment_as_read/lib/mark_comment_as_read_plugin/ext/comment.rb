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
    person && people.find(:first, :conditions => {:id => person.id})
  end

  def self.marked_as_read(person)
    find(:all, :joins => [:read_comments], :conditions => {:author_id => person.id})
  end

end
