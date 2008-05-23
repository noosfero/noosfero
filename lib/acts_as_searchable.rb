class << ActiveRecord::Base

  def acts_as_searchable(options = {})
    acts_as_ferret({ :remote => true }.merge(options))
    def find_by_contents(*args)
      find_with_ferret(*args)
    end
  end

end
