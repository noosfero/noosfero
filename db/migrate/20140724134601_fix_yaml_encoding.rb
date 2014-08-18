class FixYamlEncoding < ActiveRecord::Migration
  def self.up
    fix_encoding(Block, 'settings')
    fix_encoding(Product, 'data')
    fix_encoding(Environment, 'settings')
    fix_encoding(Profile, 'data')
    fix_encoding(ActionTracker::Record, 'params')
    fix_encoding(Article, 'setting')
  end

  def self.down
    puts "Warning: cannot restore original encoding"
  end

  private

  def self.fix_encoding(model, param)
    result = model.find(:all, :conditions => "#{param} LIKE '%!binary%'")
    puts "Fixing #{result.count} rows of #{model} (#{param})"
    result.each {|r| r.update_column(param, deep_fix(r.send(param)).to_yaml)}
  end

  def self.deep_fix(hash)
    hash.each do |value|
      value.force_encoding('UTF-8') if value.is_a?(String) && !value.frozen? && value.encoding == Encoding::ASCII_8BIT
      deep_fix(value) if value.respond_to?(:each)
    end
  end

end
