# monkey patch to remove a single error from the errors collection
# http://dev.rubyonrails.org/ticket/8137

ActiveRecord::Errors.module_eval do
  # remove a single error from the errors collection by key
  def delete(key)
    @errors.delete(key.to_s)
  end
end
