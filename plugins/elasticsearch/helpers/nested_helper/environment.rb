module NestedEnvironment

  def self.environment_hash
    {
      :id         => { type: :integer },
      :is_default => {type: :boolean }
    }
  end

  def self.environment_filter environment=1
    {
      query: {
        nested: {
          path: "environment",
          query: {
            bool: {
              must: { term: { "environment.id" => environment } },
            }
          }
        }
      }
    }
  end

end
