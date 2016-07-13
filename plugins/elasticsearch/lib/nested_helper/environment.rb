module NestedEnvironment

  def self.hash
    {
      :id         => { type: :integer },
      :is_default => {type: :boolean }
    }
  end

  def self.filter environment=1
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
