Given /^the following plugin?$/ do |table|
  table.hashes.each do |row|
    row = row.dup
    klass_name = row.delete('klass')
    eval("class #{klass_name} < Noosfero::Plugin; end;") unless eval("defined?(#{klass_name})")
  end
end

Given /^the following events of (.+)$/ do |plugin,table|
  klass = eval(plugin)
  table.hashes.each do |row|
    row = row.dup
    event = row.delete('event').to_sym
    body = eval(row.delete('body'))

    klass.class_eval do
      define_method(event) do
          body.call
      end
    end
  end
end

Given /^plugin (.+) is (enabled|disabled) on environment$/ do |plugin, status|
  e = Environment.default
  plugin = "#{plugin}Plugin"
  if status == 'enabled'
    e.enabled_plugins += [plugin]
  else
    e.enabled_plugins -= [plugin]
  end
  e.save!
end
