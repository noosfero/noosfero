class MoveTitleToNameFromBlogs < ActiveRecord::Migration
  def self.up
    Blog.find(:all).each do |blog|
      blog.name = blog.title
      blog.save
    end
  end

  def self.down
    Blog.find(:all).each do |blog|
      blog.title = blog.name
      blog.save
    end
  end
end
