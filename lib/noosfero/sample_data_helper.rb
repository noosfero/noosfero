module Noosfero::SampleDataHelper
  # tourn on autoflush
  STDOUT.sync = true

  environment_id = ARGV.first
  $environment = unless environment_id.blank?
    Environment.find(environment_id)
  else
    Environment.default || Environment.create!(:name => 'Noosfero', :is_default => true)
  end

  def save(obj, &block)
    begin
      if obj.save
        print '.'
        instance_eval &block if block
        return obj
      else
        print 'F'
      end
    rescue
      print 'E'
    end
    return nil
  end

  def done
    puts ' done!'
  end
end
