require 'test_helper'

class IndexModelsTest < ActiveSupport::TestCase

  should "check index models on elasticsearch" do
    fields = []
    mappings = []

    ActiveRecord::Base.descendants.each do |model|
      if model.const_defined?("SEARCHABLE_FIELDS")
        mappings << model.mappings.instance_values['mapping'].keys.sort
        fields << model::SEARCHABLE_FIELDS.keys.sort
      end
    end

    mappings.count.times do |i|
      assert_equal mappings[i], fields[i]
    end
  end

end
