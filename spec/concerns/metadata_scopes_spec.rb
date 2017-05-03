require 'spec_helper'

shared_examples_for "having metadata" do
  let(:model) { described_class } # the class that includes the concern

  it "fetchs by metadata key and value" do
    instance = fast_create(model)
    instance.metadata['cool'] = 'nice'
    instance.save!
    expect(model.with_metadata(cool: 'nice')).to eq([instance])
  end
end
