module NestedProfile

  def self.hash
    {
      :id             => { type: :integer },
      :visible        => { type: :boolean },
      :public_profile => { type: :boolean }
    }
  end

  def self.filter
    {
      query: {
        nested: {
          path: "profile",
          query: {
            bool: {
              must:[
                { term: { "profile.visible" => true } },
                { term: { "profile.public_profile" => true } }
              ],
            }
          }
        }
      }
    }
  end

end
