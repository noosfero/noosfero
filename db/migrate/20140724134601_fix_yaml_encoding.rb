class FixYamlEncoding < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      fix_encoding(Environment, 'settings')
      fix_encoding(Profile, 'data')
      fix_encoding(Product, 'data')
      fix_encoding(ActionTracker::Record, 'params')
      fix_encoding(Article, 'setting')
      fix_encoding(Task, 'data')
      fix_encoding(Block, 'settings')
    end
  end

  def self.down
    puts "Warning: cannot restore original encoding"
  end

  private

  def self.fix_encoding(model, param)
    puts "Fixing #{model.count} rows of #{model} (#{param})"
    model.find_each do |r|
      begin
        yaml = r.send(param)
        # if deserialization failed then a string is returned
        if yaml.is_a? String
          yaml.gsub! ': `', ': '
          yaml = YAML.load yaml
        end
        r.update_column param, deep_fix(yaml).to_yaml
      rescue => e
        puts "FAILED #{r.inspect}"
        puts e.message
      end
    end
  end

  def self.deep_fix(hash)
    hash.each do |value|
      deep_fix(value) if value.respond_to?(:each)
      if value.is_a? String and not value.frozen?
        if value.encoding == Encoding::ASCII_8BIT
          value.force_encoding "utf-8"
        else
          value.encode!("iso-8859-1").force_encoding("utf-8")
        end
      end
    end
  end

end
