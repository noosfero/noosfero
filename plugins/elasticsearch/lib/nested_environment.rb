module NestedEnvironment
  def self.environment_hash
    {
      :id         => { type: :integer },
      :is_default => {type: :boolean }
    }
  end
end
