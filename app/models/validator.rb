class Validator
  include ActiveRecord::Validations
  def new_record?
    true
  end
end
