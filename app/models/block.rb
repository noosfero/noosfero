class Block < ActiveRecord::Base

  # to be able to generate HTML
  include ActionView::Helpers::TagHelper

  acts_as_list :scope => :box
  belongs_to :box

  serialize :settings, Hash
  def settings
    self[:settings] ||= Hash.new
  end

  def self.description
    _('A dummy block.')
  end

  def content(main_content = nil)
    "This is block number %d" % self.id
  end

  def editor
    nil
  end

  def main?
    false
  end

  def owner
    box ? box.owner : nil
  end

end
