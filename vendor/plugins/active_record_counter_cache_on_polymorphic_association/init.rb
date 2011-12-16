# monkey patch to fix ActiveRecord bug
#
# https://rails.lighthouseapp.com/projects/8994/tickets/2452-counter_cache-not-updated-when-an-item-updates-its-polymorphic-owner

ActiveRecord::Associations::ClassMethods.module_eval do

  def replace(record)
    counter_cache_name = @reflection.counter_cache_column
    if record.nil?
      if counter_cache_name && !@owner.new_record?
        record.class.base_class.decrement_counter(counter_cache_name, @owner[@reflection.primary_key_name]) if @owner[@reflection.primary_key_name]
      end
      @target = @owner[@reflection.primary_key_name] = @owner[@reflection.options[:foreign_type]] = nil
    else
      @target = (AssociationProxy === record ? record.target : record)

      if counter_cache_name && !@owner.new_record?
        record.class.base_class.increment_counter(counter_cache_name, record.id)
        record.class.base_class.decrement_counter(counter_cache_name, @owner[@reflection.primary_key_name]) if @owner[@reflection.primary_key_name]
      end

      @owner[@reflection.primary_key_name] = record.id
      @owner[@reflection.options[:foreign_type]] = record.class.base_class.name.to_s

      @updated = true
    end

    loaded
    record
  end

end
