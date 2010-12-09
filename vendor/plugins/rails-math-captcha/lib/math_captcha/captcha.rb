require 'rubygems'
require 'ezcrypto'
class Captcha
  NUMBERS   = (1..9).to_a
  OPERATORS = [:+, :-, :*]

  attr_reader :x, :y, :operator

  def initialize(x=nil, y=nil, operator=nil)
    @x = x || NUMBERS.sort_by{rand}.first
    @y = y || NUMBERS.sort_by{rand}.first
    @operator = operator || OPERATORS.sort_by{rand}.first
  end

  # Only the #to_secret is shared with the client.
  # It can be reused here to create the Captcha again
  def self.from_secret(secret)
    yml = cipher.decrypt64 secret
    args = YAML.load(yml)
    new(args[:x], args[:y], args[:operator])
  end

  def self.cipher
    EzCrypto::Key.with_password key, 'bad_fixed_salt'
  end

  def self.key
    'ultrasecret'
  end

  
  def check(answer)
    answer == solution
  end
  
  def task
    "#{@x} #{@operator.to_s} #{@y}"
  end
  def task_with_questionmark
    "#{@x} #{@operator.to_s} #{@y} = ?"
  end
  alias_method :to_s, :task

  def solution
    @x.send @operator, @y
  end

  def to_secret
    cipher.encrypt64(to_yaml)
  end

  def to_yaml
    YAML::dump({
      :x => x,
      :y => y,
      :operator => operator
    })
  end

  private
  def cipher
    @cipher ||= self.class.cipher
  end
  def reset_cipher
    @cipher = nil
  end

end
