module Spammable
  def self.included(recipient)
    #TODO This line crashes the migration which includes the spam attribute to
    #     Task...  =P
    #     No fail-safe until someone find out how to use this without crashing
    #     the migration process
    #raise "This model (#{recipient.to_s}) should have a spam attribute!" if !recipient.new.respond_to?('spam=')
    recipient.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended (base)
      if base.respond_to?(:scope)
        base.class_eval do
          scope :without_spam, :conditions => ['spam IS NULL OR spam = ?', false]
          scope :spam, :conditions => ['spam = ?', true]
        end
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
