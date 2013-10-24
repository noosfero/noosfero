module Spammable
  def self.included(recipient)
    recipient.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended (base)
      base.class_eval do
        named_scope :without_spam, :conditions => ['spam IS NULL OR spam = ?', false]
        named_scope :spam, :conditions => ['spam = ?', true]
      end
    end
  end

  def spam?
    !spam.nil? && spam
  end

  def ham?
    !spam.nil? && !spam
  end

  def spam!
    before_spam!
    self.spam = true
    self.save!
    after_spam!
    self
  end

  def ham!
    before_ham!
    self.spam = false
    self.save!
    after_ham!
    self
  end

  def after_spam!; end
  def before_spam!; end

  def after_ham!; end
  def before_ham!; end
end
