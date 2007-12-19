class Comment < ActiveRecord::Base
  validates_presence_of :title, :body
  belongs_to :article
  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'
end
