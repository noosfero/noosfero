class Block < ActiveRecord::Base
  acts_as_list :scope => :box
  belongs_to :box

  def content(main_content = nil)
    "This is block number %d" % self.id
  end

  def editor
    { :controller => 'block_editor', :id => self.id }
  end

end
