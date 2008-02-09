class Block < ActiveRecord::Base

  # to be able to generate HTML
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  # Block-specific stuff
  include BlockHelper

  acts_as_list :scope => :box
  belongs_to :box

  acts_as_having_settings

  def self.description
    _('A dummy block.')
  end

  # TODO: must have some way to have access to request information (mainly the
  # current user)
  def content
    "This is block number %d" % self.id
  end

  # must return a Hash with URL options poiting to the action that edits
  # properties of the block
  def editor
    nil
  end

  # must always return false, except on MainBlock clas.
  def main?
    false
  end

  def owner
    box ? box.owner : nil
  end

  def css_class_name
    self.class.name.underscore.gsub('_', '-')
  end

end
