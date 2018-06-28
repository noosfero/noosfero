require_relative '../spec_helper'

describe Profile do
  it_behaves_like "having metadata"

  let(:profile) { fast_create(Profile) }

  describe '#exportable_fields' do
    let(:fields) { profile.exportable_fields }
    let(:active_fields) { %w[field1 field2 field3] }
    let(:extra_fields) { %w(extra_field1 extra_field2) }

    before do
      expect(profile).to receive(:active_fields).and_return(active_fields)
    end

    it { expect(fields).to include(*Person::DEFAULT_EXPORTABLE_FIELDS) }
    it { expect(fields).to include(*active_fields) }
    it { expect(fields).not_to include(*extra_fields) }

    context 'there is a plugin adding exportable fields' do
      before do
        class FooPlugin < Noosfero::Plugin
          def extra_exportable_fields(profile)
            %w(extra_field1 extra_field2)
          end
        end

        expect(Noosfero::Plugin).to receive(:all).at_least(:once)
          .and_return(['FooPlugin'])
        Environment.default.enable_plugin FooPlugin
      end

      it { expect(fields).to include(*extra_fields) }
    end
  end
end
